//
//  ScanSession.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation

struct ScanSession: Identifiable, Codable, Hashable {
    let id: UUID
    let startedAt: Date
    let finishedAt: Date
    let bluetoothDevices: [BluetoothDevice]
    let lanDevices: [LanDevice]
}
