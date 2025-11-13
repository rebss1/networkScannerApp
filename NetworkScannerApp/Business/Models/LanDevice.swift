//
//  LanDevice.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation

public struct LanDevice: Identifiable, Hashable, Codable {
    public var id: UUID
    public let ipAddress: String
    public let macAddress: String?
    public let hostname: String?
}
