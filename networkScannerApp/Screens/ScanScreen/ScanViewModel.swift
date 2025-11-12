//
//  ScanViewModel.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import Combine

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var isScanning = false
    @Published var progress: Double = 0
    @Published var bluetoothDevices: [BluetoothDevice] = []
    @Published var bluetoothState: BluetoothState = .unknown
    @Published var alert: ScanAlert?
    @Published var lanHosts: [LanHost] = []

    private let bt: BluetoothScanningService
    private let lan: LanScanningService
    private var cancellables = Set<AnyCancellable>()
    private let repo: Repository

    private var scanStart: Date?
    private var scanDuration: TimeInterval = 15.0
    private var progressTimer: Timer?

    init(
        bt: BluetoothScanningService = CoreBluetoothScanner(),
        lan: LanScanningService = LanScanAdapter(),
        repo: Repository = (try? RealmRepository()) ?? { fatalError("Realm init failed") }()
    ) {
        self.bt = bt
        self.lan = lan
        self.repo = repo

        bt.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.bluetoothState = $0 }
            .store(in: &cancellables)

        bt.devicesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.bluetoothDevices = $0 }
            .store(in: &cancellables)

        lan.devicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] host in
                self?.lanHosts.append(host)
            }
            .store(in: &cancellables)
    }

    func startScan(duration: TimeInterval = 15) {
        guard !isScanning else { return }
        isScanning = true
        progress = 0
        scanDuration = duration
        scanStart = Date()

        // Параллельный старт: BT — только если включён, LAN — всегда
        if bluetoothState != .poweredOn {
            alert = .bluetoothOff
        }

        bluetoothDevices = []
        lanHosts = []

        if bluetoothState == .poweredOn {
            bt.startScan(timeout: duration)
        }
        lan.start(timeout: duration)

        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] t in
            guard let self = self, let start = self.scanStart else { t.invalidate(); return }
            let elapsed = Date().timeIntervalSince(start)
            Task { @MainActor in
                self.progress = min(1, elapsed / self.scanDuration)
                if elapsed >= self.scanDuration {
                    t.invalidate()
                    self.finishScan()
                }
            }
        }
        RunLoop.main.add(progressTimer!, forMode: .common)
    }

    func stopScanEarly() {
        guard isScanning else { return }
        bt.stopScan()
        lan.stop()
        finishScan()
    }

    private func finishScan() {
        isScanning = false
        progressTimer?.invalidate()
        progressTimer = nil
        let finishedAt = Date()
        do {
            try repo.saveSession(
                startedAt: scanStart ?? finishedAt,
                finishedAt: finishedAt,
                bluetooth: bluetoothDevices,
                lan: lanHosts
            )
            alert = .completed(total: bluetoothDevices.count + lanHosts.count)
        } catch {
            alert = .error(message: "Не удалось сохранить результаты: \(error.localizedDescription)")
        }
    }
}

enum ScanAlert: Equatable, Identifiable {
    case bluetoothOff
    case permissionDenied
    case completed(total: Int)
    case error(message: String)
    
    var id: String {
        switch self {
        case .bluetoothOff: return "bluetoothOff"
        case .permissionDenied: return "permissionDenied"
        case let .completed(total): return "completed-\(total)"
        case let .error(msg): return "error-\(msg)"
        }
    }
}
