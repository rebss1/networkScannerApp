//
//  CoreBluetoothScanner.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import CoreBluetooth
import Combine
import FactoryKit

final class CoreBluetoothScanner: NSObject, BluetoothScanningService {
    
    // MARK: - Properties

    var statePublisher: AnyPublisher<BluetoothState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var devicesPublisher: AnyPublisher<[BluetoothDevice], Never> {
        devicesSubject.eraseToAnyPublisher()
    }
    
    private var central: CBCentralManager?
    private let stateSubject = CurrentValueSubject<BluetoothState, Never>(.unknown)
    private let devicesSubject = CurrentValueSubject<[BluetoothDevice], Never>([])
    private var discovered: [UUID: BluetoothDevice] = [:]

    // MARK: - Init

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Methods

    func startScan(timeout: TimeInterval = 15) {
        guard central?.state == .poweredOn else { return }
        discovered.removeAll()
        central?.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    func stopScan() {
        central?.stopScan()
    }
}

// MARK: - CBCentralManagerDelegate

extension CoreBluetoothScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let mapped: BluetoothState
        switch central.state {
        case .unknown:
            mapped = .unknown
        case .resetting:
            mapped = .resetting
        case .unsupported:
            mapped = .unsupported
        case .unauthorized:
            mapped = .unauthorized
        case .poweredOff:
            mapped = .poweredOff
        case .poweredOn:
            mapped = .poweredOn
        default:
            mapped = .unknown
        }
        stateSubject.send(mapped)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        var device = BluetoothDevice(
            id: peripheral.identifier,
            name: peripheral.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String),
            rssi: RSSI.intValue,
            state: {
                switch peripheral.state {
                case .connected:
                    return "connected"
                case .connecting:
                    return "connecting"
                case .disconnected:
                    return "disconnected"
                case .disconnecting:
                    return "disconnecting"
                default:
                    return "unknown"
                }
            }()
        )
        device.lastSeen = Date()
        discovered[device.id] = device
        let snapshot = Array(discovered.values).sorted { ($0.name ?? "") < ($1.name ?? "") }
        devicesSubject.send(snapshot)
    }
}

extension Container {
    var bluetoothScanningService: Factory<BluetoothScanningService> {
        self { CoreBluetoothScanner() }.unique
    }
}
