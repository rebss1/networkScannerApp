//
//  LanHost.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation

public struct LanHost: Identifiable, Hashable, Codable {
    public var id: String { ipAddress }
    public let ipAddress: String
    public let macAddress: String?
    public let hostname: String?
}

