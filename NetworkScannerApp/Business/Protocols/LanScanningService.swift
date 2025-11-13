//
//  LanScanningService.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import Combine

public protocol LanScanningService {
    var devicePublisher: AnyPublisher<LanDevice, Never> { get }
    var progressPublisher: AnyPublisher<(pinged: Int, total: Int), Never> { get }
    var finishPublisher: AnyPublisher<Void, Never> { get }
    var isWifiEnabled: Bool { get }
    
    func start(timeout: TimeInterval)
    func stop()
}
