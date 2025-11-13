//
//  ScanViewModel.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI
import Combine
import FactoryKit

@MainActor
final class ScanViewModel: ObservableObject {
    
    // MARK: - Properties

    @Injected(\.bluetoothScanningService) private var bluetoothScanningService
    @Injected(\.lanScanningService) private var lanScanningService
    @Injected(\.repository) private var repository
    
    @Published var isScanning = false
    @Published var progress: Double = 0
    @Published var bluetoothState: BluetoothState = .unknown
    @Published var lastSavedSessionId: UUID?
    @Published var shouldOpenLastSession = false
    @Published var showDevicesList = false

    private var cancellables = Set<AnyCancellable>()
    private var collectedBT: [BluetoothDevice] = []
    private var collectedLAN: [LanDevice] = []
    
    private var scanStart: Date?
    private var scanDuration: TimeInterval = 15.0
    
    // MARK: - Init

    init() {
        bind()
    }
    
    // MARK: - Methods

    func startScan() {
        guard !isScanning else { return }

        let btOn = bluetoothState == .poweredOn
        let wifiOn = lanScanningService.isWifiEnabled

        if !btOn && !wifiOn {
            Popup.showAlert(
                title: "Ошибка",
                message: "Bluetooth и Wi-Fi выключены. Сканирование невозможно.",
                buttonTitle: "OK",
                onTap: nil
            )
            return
        }

        if !btOn && wifiOn {
            Popup.showConfirm(
                title: "Bluetooth выключен",
                message: "Продолжить сканирование только по Wi-Fi (LAN)?",
                yesTitle: "Продолжить",
                noTitle: "Отмена",
                onYes: { [weak self] in
                    self?.startScan(scanBT: false, scanLAN: true)
                }
            )
            return
        }

        if btOn && !wifiOn {
            Popup.showConfirm(
                title: "Wi-Fi выключен",
                message: "Продолжить сканирование только по Bluetooth?",
                yesTitle: "Продолжить",
                noTitle: "Отмена",
                onYes: { [weak self] in
                    self?.startScan(scanBT: true, scanLAN: false)
                }
            )
            return
        }

        startScan(scanBT: true, scanLAN: true)
    }
    
    func stopScanEarly() {
        guard isScanning else { return }
        bluetoothScanningService.stopScan()
        lanScanningService.stop()
        finishScan()
    }
    
    private func startScan(scanBT: Bool, scanLAN: Bool) {
        isScanning = true
        progress = 0
        scanStart = Date()

        collectedBT = []
        collectedLAN = []

        if scanBT {
            bluetoothScanningService.startScan(timeout: scanDuration)
        }
        if scanLAN {
            lanScanningService.start(timeout: scanDuration)
        }

        Task { [weak self] in
            guard let self else { return }
            let start = Date()
            
            while true {
                try? await Task.sleep(nanoseconds: 100_000_000)
                
                await MainActor.run {
                    guard self.isScanning else { return }
                    
                    let elapsed = Date().timeIntervalSince(start)
                    self.progress = min(1, elapsed / self.scanDuration)
                    
                    if elapsed >= self.scanDuration {
                        self.finishScan()
                    }
                }
                
                if await MainActor.run(body: { self.isScanning == false }) {
                    break
                }
            }
        }
    }
    
    private func finishScan() {
        isScanning = false
        let finishedAt = Date()
        
        do {
            let sessionId = try repository.saveSession(
                startedAt: scanStart ?? finishedAt,
                finishedAt: finishedAt,
                bluetooth: collectedBT,
                lan: collectedLAN
            )
            
            lastSavedSessionId = sessionId
            let total = collectedBT.count + collectedLAN.count
            
            Popup.showConfirm(
                title: "Готово",
                message: "Найдено устройств: \(total)",
                yesTitle: "Открыть",
                noTitle: "Закрыть",
                onYes: { [weak self] in
                    self?.showDevicesList = true
                }
            )
        } catch {
            Popup.showAlert(
                title: "Ошибка",
                message: "Не удалось сохранить результаты: \(error.localizedDescription)",
                buttonTitle: "OK",
                onTap: nil
            )
        }
        
        progress = 0
    }
    
    private func bind() {
        bluetoothScanningService.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.bluetoothState = $0 }
            .store(in: &cancellables)

        bluetoothScanningService.devicesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                self?.collectedBT = devices
            }
            .store(in: &cancellables)

        lanScanningService.devicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] host in
                self?.collectedLAN.append(host)
            }
            .store(in: &cancellables)
    }
}
