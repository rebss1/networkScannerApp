//
//  ScanView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct ScanView: View {
    
    @StateObject private var viewModel = ScanViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                
                Spacer()
                
                Text("Сканирование… \(Int(viewModel.progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScanCircleView(isScanning: viewModel.isScanning)
                    .onTapGesture {
                        viewModel.isScanning ? viewModel.stopScanEarly() : viewModel.startScan()
                    }
                
                Text("Нажмите кнопку выше, чтобы начать поиск устройств")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(
                    isActive: Binding(
                        get: { viewModel.showDevicesList },
                        set: { viewModel.showDevicesList = $0 }
                    ),
                    destination: {
                        if let id = viewModel.lastSavedSessionId {
                            DevicesListView(sessionId: id)
                        }
                    },
                    label: { EmptyView() }
                )
                .hidden()
            }
            .navigationTitle("Сканирование")
        }
    }
}
