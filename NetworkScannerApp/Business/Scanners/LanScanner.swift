//
//  LanScanner.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import Combine
import MMLanScan
import FactoryKit
 
final class LanScanner: NSObject, LanScanningService, MMLANScannerDelegate {
    
    // MARK: - Properties

    var devicePublisher: AnyPublisher<LanDevice, Never> {
        deviceSubject.eraseToAnyPublisher()
    }
    
    var progressPublisher: AnyPublisher<(pinged: Int, total: Int), Never> {
        progressSubject.map { (pinged: $0.0, total: $0.1) }.eraseToAnyPublisher()
    }
    
    var finishPublisher: AnyPublisher<Void, Never> {
        finishSubject.eraseToAnyPublisher()
    }
    
    private var scanner: MMLANScanner?
    private let deviceSubject = PassthroughSubject<LanDevice, Never>()
    private let progressSubject = PassthroughSubject<(Int, Int), Never>()
    private let finishSubject = PassthroughSubject<Void, Never>()
    private var timeoutCancellable: AnyCancellable?

    // MARK: - Methods
    
    func start(timeout: TimeInterval = 15) {
        scanner = MMLANScanner(delegate: self)
        scanner?.start()
        timeoutCancellable = Just(())
            .delay(for: .seconds(timeout), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.stop() }
    }

    func stop() {
        scanner?.stop()
        finishSubject.send(())
        finishSubject.send(completion: .finished)
        timeoutCancellable?.cancel()
    }
    
    func lanScanDidFindNewDevice(_ device: MMDevice?) {
        guard let device else { return }
        let host = LanDevice(
            id: UUID(),
            ipAddress: device.ipAddress ?? "",
            macAddress: device.macAddress,
            hostname: device.hostname
        )
        deviceSubject.send(host)
    }

    func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
        finishSubject.send(())
    }
    
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        progressSubject.send((Int(pingedHosts), overallHosts))
    }
    
    func lanScanDidFailedToScan() {
        finishSubject.send(())
    }
}

extension Container {
    var lanScanningService: Factory<LanScanningService> {
        self { LanScanner() }.unique
    }
}
