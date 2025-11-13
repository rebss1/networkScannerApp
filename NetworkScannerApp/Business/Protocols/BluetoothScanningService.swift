//
//  BluetoothScanningService.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import Combine

protocol BluetoothScanningService {
    var statePublisher: AnyPublisher<BluetoothState, Never> { get }
    var devicesPublisher: AnyPublisher<[BluetoothDevice], Never> { get }
    
    func startScan(timeout: TimeInterval)
    func stopScan()
}
