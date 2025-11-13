//
//  Repository.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation

protocol Repository {
    func saveSession(startedAt: Date, finishedAt: Date, bluetooth: [BluetoothDevice], lan: [LanDevice]) throws -> UUID
    func fetchSessions(filterName: String?, from: Date?, to: Date?) throws -> [ScanSession]
    func fetchSession(by id: UUID) throws -> ScanSession?
}
