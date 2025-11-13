//
//  DevicesListView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import SwiftUI

struct DevicesListView: View {
    
    // MARK: - Properties
    
    private let viewModel: DevicesListViewModel
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("Bluetooth")
                    .font(.headline)
                
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.btDevices) { device in
                        NavigationLink {
                            DeviceDetailView(device: .bluetooth(device))
                        } label: {
                            DeviceView(
                                iconName: "bolt.horizontal.circle",
                                title: device.name,
                                subtitle: device.id.uuidString
                            )
                        }
                    }
                }
                
                Text("LAN")
                    .font(.headline)
                
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.lanDevices) { device in
                        NavigationLink {
                            DeviceDetailView(device: .lan(device))
                        } label: {
                            DeviceView(
                                iconName: "network",
                                title: device.ipAddress,
                                subtitle: device.id.uuidString
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Init

    init(sessionId: UUID) {
        self.viewModel = DevicesListViewModel(sessionId: sessionId)
    }
}
