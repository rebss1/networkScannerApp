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

    private var iconName: String {
        switch device {
        case .bluetooth:
            return "bolt.horizontal.circle.fill"
        case .lan:
            return "network"
        }
    }
    
    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 16) {
                switch device {
                case .bluetooth(let device):
                    bluetoothSection(device)
                case .lan(let device):
                    lanSection(device)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 38)
                    .fill(.ultraThinMaterial)
            )
            
            Spacer()
        }
        .padding(.top, 100)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .top)
        .navigationTitle("Устройство")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Methods

    private func bluetoothSection(_ device: BluetoothDevice) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bluetooth")
                .font(.headline)

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
                .font(.headline)

            infoRow("Имя (hostname)", device.hostname ?? "Неизвестно")
            infoRow("IP", device.ipAddress)
            infoRow("MAC", device.macAddress ?? "Неизвестно")
        }
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .standard)
    }
}
