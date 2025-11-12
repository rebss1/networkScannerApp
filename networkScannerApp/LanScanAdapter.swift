//
//  LanScanAdapter.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import Combine
import MMLanScan

final class LanScanAdapter: NSObject, LanScanningService, MMLANScannerDelegate {
    private var scanner: MMLANScanner?
    private let deviceSubject = PassthroughSubject<LanHost, Never>()
    private let progressSubject = PassthroughSubject<(Int, Int), Never>()
    private let finishSubject = PassthroughSubject<Void, Never>()
    private var timeoutCancellable: AnyCancellable?

    var devicePublisher: AnyPublisher<LanHost, Never> { deviceSubject.eraseToAnyPublisher() }
    var progressPublisher: AnyPublisher<(pinged: Int, total: Int), Never> {
        progressSubject.map { (pinged: $0.0, total: $0.1) }.eraseToAnyPublisher()
    }
    var finishPublisher: AnyPublisher<Void, Never> { finishSubject.eraseToAnyPublisher() }

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

    // MARK: - MMLANScannerDelegate
    func lanScanDidFindNewDevice(_ device: MMDevice!) {
        let host = LanHost(
            ipAddress: device.ipAddress ?? "",
            macAddress: device.macAddress,   // На iOS 11+ может быть nil — это ожидаемо
            hostname: device.hostname
        )
        deviceSubject.send(host)
    }

    func lanScanDidFinishScanning(with status: MMLanScannerStatus) { finishSubject.send(()) }
    func lanScanProgressPinged(_ pingedHosts: Float, from overallHosts: Int) {
        progressSubject.send((Int(pingedHosts), overallHosts))
    }
    func lanScanDidFailedToScan() { finishSubject.send(()) }
}
