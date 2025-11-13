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
        isScanning = true
        progress = 0
        scanStart = Date()
        
        if bluetoothState != .poweredOn {
            Popup.showAlert(
                title: "Bluetooth выключен",
                message: "Включите Bluetooth в настройках.",
                buttonTitle: "OK",
                onTap: nil
            )
        }
        
        collectedBT = []
        collectedLAN = []
        
        if bluetoothState == .poweredOn {
            bluetoothScanningService.startScan(timeout: scanDuration)
        }
        lanScanningService.start(timeout: scanDuration)
        
        Task { [weak self] in
            guard let self else { return }
            let start = Date()
            while self.isScanning {
                try? await Task.sleep(nanoseconds: 100_000_000)
                let elapsed = Date().timeIntervalSince(start)
                await MainActor.run {
                    self.progress = min(1, elapsed / self.scanDuration)
                    if elapsed >= self.scanDuration {
                        self.finishScan()
                    }
                }
            }
        }
    }
    
    func stopScanEarly() {
        guard isScanning else { return }
        bluetoothScanningService.stopScan()
        lanScanningService.stop()
        finishScan()
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
