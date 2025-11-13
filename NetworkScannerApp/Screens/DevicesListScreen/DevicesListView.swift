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
        NavigationView {
            contentView
        }
    }
    
    // MARK: - Subviews

    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("Bluetooth")
                    .font(.headline)
                
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.btDevices) { device in
                        DeviceView(
                            iconName: "bolt.horizontal.circle",
                            title: device.name,
                            subtitle: device.id.uuidString
                        )
                        .onTapGesture {
                            viewModel.showDetailsView(with: .bluetooth(device))
                        }
                    }
                }
                
                Text("LAN")
                    .font(.headline)
                
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.lanDevices) { device in
                        DeviceView(
                            iconName: "bolt.horizontal.circle",
                            title: device.ipAddress,
                            subtitle: device.id.uuidString
                        )
                        .onTapGesture {
                            viewModel.showDetailsView(with: .lan(device))
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
