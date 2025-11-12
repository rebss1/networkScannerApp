//
//  ScanScreen.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct ScanScreen: View {
    @StateObject private var vm = ScanViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if vm.isScanning {
                    ProgressView(value: vm.progress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal)
                    Text("Сканирование… \(Int(vm.progress * 100))%")
                        .font(.caption)
                } else {
                    Text("Нажмите «Начать», чтобы просканировать устройства по Bluetooth")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                HStack {
                    Button(vm.isScanning ? "Остановить" : "Начать") {
                        vm.isScanning ? vm.stopScanEarly() : vm.startScan()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Очистить") {
                        vm.bluetoothDevices = []
                    }
                    .buttonStyle(.bordered)
                }

                List(vm.bluetoothDevices) { d in
                    DeviceRowBT(device: d)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Сканирование")
            .alert(item: $vm.alert) { alert in
                switch alert {
                case .bluetoothOff:
                    return Alert(title: Text("Bluetooth выключен"),
                                 message: Text("Включите Bluetooth в настройках."),
                                 dismissButton: .default(Text("OK")))
                case .permissionDenied:
                    return Alert(title: Text("Нет доступа"),
                                 message: Text("Разрешите доступ к Bluetooth в Настройках."),
                                 dismissButton: .default(Text("OK")))
                case .completed(let total):
                    return Alert(title: Text("Готово"),
                                 message: Text("Найдено устройств: \(total)"),
                                 dismissButton: .default(Text("OK")))
                case .error(let msg):
                    return Alert(title: Text("Ошибка"),
                                 message: Text(msg),
                                 dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}

struct DeviceRowBT: View {
    let device: BluetoothDevice
    var body: some View {
        HStack {
            Image(systemName: "bolt.horizontal.circle")
            VStack(alignment: .leading, spacing: 2) {
                Text(device.name ?? "Неизвестное устройство")
                Text(device.id.uuidString).font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            if let rssi = device.rssi {
                Text("\(rssi) dBm").font(.caption)
            }
        }
    }
}
