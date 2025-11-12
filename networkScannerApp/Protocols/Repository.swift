//
//  Repository.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation

protocol Repository {
    func saveSession(startedAt: Date, finishedAt: Date, bluetooth: [BluetoothDevice], lan: [LanHost]) throws
    func fetchSessions(filterName: String?, from: Date?, to: Date?) throws -> [ScanSession]
}
