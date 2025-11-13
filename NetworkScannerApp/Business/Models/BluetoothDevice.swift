//
//  BluetoothDevice.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation

struct BluetoothDevice: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String?
    var rssi: Int?
    var state: String?
    var lastSeen: Date = .init()

    init(id: UUID, name: String?, rssi: Int?, state: String?) {
        self.id = id
        self.name = name
        self.rssi = rssi
        self.state = state
    }
}
