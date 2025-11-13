//
//  RDevice.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import RealmSwift

final class RDevice: Object {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var kind: String = DeviceType.bluetooth.rawValue
    @Persisted var name: String?
    @Persisted var uuid: String?
    @Persisted var rssi: Int?
    @Persisted var status: String?
    @Persisted var ip: String?
    @Persisted var mac: String?
    @Persisted var lastSeen: Date = .init()
}
