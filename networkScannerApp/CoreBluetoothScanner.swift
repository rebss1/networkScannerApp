//
//  CoreBluetoothScanner.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import CoreBluetooth
import Combine

final class CoreBluetoothScanner: NSObject, BluetoothScanningService {
    private var central: CBCentralManager!
    private let queue = DispatchQueue(label: "bt.scanner.queue")

    private let stateSubject = CurrentValueSubject<BluetoothState, Never>(.unknown)
    private let devicesSubject = CurrentValueSubject<[BluetoothDevice], Never>([])

    private var discovered: [UUID: BluetoothDevice] = [:]
    private var scanTimer: Timer?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: queue)
    }

    // MARK: - BluetoothScanningService

    var statePublisher: AnyPublisher<BluetoothState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var devicesPublisher: AnyPublisher<[BluetoothDevice], Never> {
        devicesSubject.eraseToAnyPublisher()
    }

    func startScan(timeout: TimeInterval = 15) {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard self.central.state == .poweredOn else { return }
            self.discovered.removeAll()
            self.central.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            )

            self.scanTimer?.invalidate()
            self.scanTimer = Timer.scheduledTimer(
                withTimeInterval: timeout,
                repeats: false
            ) { [weak self] _ in
                self?.stopScan()
            }
            RunLoop.current.add(self.scanTimer!, forMode: .default)
        }
    }

    func stopScan() {
        queue.async { [weak self] in
            self?.central.stopScan()
            self?.scanTimer?.invalidate()
            self?.scanTimer = nil
        }
    }
}

extension CoreBluetoothScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let mapped: BluetoothState
        switch central.state {
        case .unknown: mapped = .unknown
        case .resetting: mapped = .resetting
        case .unsupported: mapped = .unsupported
        case .unauthorized: mapped = .unauthorized
        case .poweredOff: mapped = .poweredOff
        case .poweredOn: mapped = .poweredOn
        @unknown default: mapped = .unknown
        }
        stateSubject.send(mapped)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        var device = BluetoothDevice(
            id: peripheral.identifier,
            name: peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String),
            rssi: RSSI.intValue,
            state: {
                switch peripheral.state {
                case .connected: return "connected"
                case .connecting: return "connecting"
                case .disconnected: return "disconnected"
                case .disconnecting: return "disconnecting"
                @unknown default: return "unknown"
                }
            }()
        )
        device.lastSeen = Date()
        discovered[device.id] = device
        let snapshot = Array(discovered.values).sorted { ($0.name ?? "") < ($1.name ?? "") }
        devicesSubject.send(snapshot)
    }
}
