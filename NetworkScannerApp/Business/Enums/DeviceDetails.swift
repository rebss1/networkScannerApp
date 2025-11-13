//
//  DeviceDetails.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import Foundation

enum DeviceDetails: Identifiable {
    case bluetooth(BluetoothDevice)
    case lan(LanDevice)

    var id: UUID {
        switch self {
        case .bluetooth(let device):
            return device.id
        case .lan(let device):
            return device.id
        }
    }
}
