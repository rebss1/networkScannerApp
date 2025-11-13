//
//  DevicesListViewModel.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import SwiftUI
import FactoryKit
import Combine

final class DevicesListViewModel: ObservableObject {
    
    // MARK: - Properties

    @Injected(\.repository) private var repository: Repository
    
    @Published var btDevices: [BluetoothDevice] = []
    @Published var lanDevices: [LanDevice] = []
    @Published var scanDate: String = ""
    @Published var isLoading = false
    
    // MARK: - Init

    init(sessionId: UUID) {
        loadData(with: sessionId)
    }
    
    // MARK: - Methods

    func showDetailsView(with device: DeviceDetails) {
        Popup.show {
            DeviceDetailView(device: device)
                .padding()
        }
    }
    
    private func loadData(with sessionId: UUID) {
        isLoading = true
        do {
            let all = try repository.fetchSessions(filterName: nil, from: nil, to: nil)
            let session = all.first(where: { $0.id == sessionId })
            scanDate = session?.startedAt.formatted(date: .abbreviated, time: .standard) ?? ""
            btDevices = session?.bluetoothDevices ?? []
            lanDevices = session?.lanDevices ?? []
        } catch {
            print(error.localizedDescription)
        }
        isLoading = false
    }
}
