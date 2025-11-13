//
//  DeviceDetailView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import SwiftUI

struct DeviceDetailView: View {
    
    // MARK: - Properties

    let device: DeviceDetails

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            switch device {
            case .bluetooth(let device):
                bluetoothSection(device)
            case .lan(let device):
                lanSection(device)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        }
    }

    // MARK: - Methods

    private func bluetoothSection(_ device: BluetoothDevice) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bluetooth")
                .font(.title3.bold())
            
            infoRow("Имя", device.name ?? "Неизвестно")
            infoRow("UUID", device.id.uuidString)
            infoRow("RSSI", device.rssi.map(String.init) ?? "Нет данных")
            infoRow("Состояние", device.state ?? "Неизвестно")
            infoRow("Последний раз видел", formatDate(device.lastSeen))
        }
    }

    private func lanSection(_ device: LanDevice) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LAN")
                .font(.title3.bold())

            infoRow("Имя (hostname)", device.hostname ?? "Неизвестно")
            infoRow("IP", device.ipAddress)
            infoRow("MAC", device.macAddress ?? "Неизвестно")
            infoRow("UUID", device.id.uuidString)
        }
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .standard)
    }
}
