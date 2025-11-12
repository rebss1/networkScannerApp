//
//  HistoryScreen.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct HistoryScreen: View {
    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    TextField("Фильтр по имени", text: $vm.filterName)
                        .textFieldStyle(.roundedBorder)
                    Button("Применить") { vm.reload() }
                }
                .padding(.horizontal)

                List {
                    ForEach(vm.sessions) { s in
                        NavigationLink {
                            SessionDetailView(session: s)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(s.startedAt.formatted(date: .abbreviated, time: .standard))
                                    .font(.headline)
                                Text("BT: \(s.bluetoothDevices.count) • LAN: \(s.lanHosts.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("История")
        }
    }
}

struct DeviceRowLAN: View {
    let host: LanHost

    /// Safely extracts string properties by name using reflection to support both
    /// LanHost(ip/name/mac) and LanHost(ipAddress/hostname/macAddress) variants.
    private func string(_ key: String) -> String? {
        Mirror(reflecting: host).children.first(where: { $0.label == key })?.value as? String
    }

    var body: some View {
        // Prefer new keys (ipAddress/hostname/macAddress); fall back to old (ip/name/mac)
        let ip = string("ipAddress") ?? string("ip") ?? "—"
        let name = string("hostname") ?? string("name")
        let mac = string("macAddress") ?? string("mac")

        return HStack {
            Image(systemName: "wifi")
            VStack(alignment: .leading, spacing: 2) {
                Text(name ?? ip)
                Text(ip).font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            if let mac, !mac.isEmpty {
                Text(mac).font(.caption)
            }
        }
    }
}

struct SessionDetailView: View {
    let session: ScanSession
    var body: some View {
        List {
            Section("Bluetooth") {
                ForEach(session.bluetoothDevices) { d in
                    DeviceRowBT(device: d)
                }
            }
            Section("LAN") {
                ForEach(session.lanHosts) { h in
                    DeviceRowLAN(host: h)
                }
            }
        }
        .navigationTitle("Сессия")
    }
}
