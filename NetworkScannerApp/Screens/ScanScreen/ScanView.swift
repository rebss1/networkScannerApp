//
//  ScanView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct ScanView: View {
    
    // MARK: - Properties

    @StateObject private var viewModel = ScanViewModel()
    
    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if viewModel.isScanning {
                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal)
                    Text("Сканирование… \(Int(viewModel.progress * 100))%")
                        .font(.caption)
                } else {
                    Text("Нажмите «Начать», чтобы просканировать устройства по Bluetooth")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(viewModel.isScanning ? "Остановить" : "Начать") {
                    viewModel.isScanning ? viewModel.stopScanEarly() : viewModel.startScan()
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink(
                    isActive: Binding(
                        get: { viewModel.showDevicesList },
                        set: { viewModel.showDevicesList = $0 }
                    ),
                    destination: {
                        if let id = viewModel.lastSavedSessionId {
                            DevicesListView(sessionId: id)
                        } else {
                            EmptyView()
                        }
                    },
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            }
            .navigationTitle("Сканирование")
        }
    }
}
