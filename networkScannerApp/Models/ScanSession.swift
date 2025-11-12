//
//  ScanSession.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation

struct ScanSession: Identifiable, Codable, Hashable {
    let id: UUID
    let startedAt: Date
    let finishedAt: Date
    let bluetoothDevices: [BluetoothDevice]
    let lanHosts: [LanHost]

    init(id: UUID = .init(),
         startedAt: Date,
         finishedAt: Date,
         bluetoothDevices: [BluetoothDevice],
         lanHosts: [LanHost]) {
        self.id = id
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.bluetoothDevices = bluetoothDevices
        self.lanHosts = lanHosts
    }
}
