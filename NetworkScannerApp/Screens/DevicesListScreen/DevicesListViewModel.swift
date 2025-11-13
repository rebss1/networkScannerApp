//
//  DevicesListViewModel.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import SwiftUI
import FactoryKit
import Combine

@MainActor
final class DevicesListViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @LazyInjected(\.repository) private var repository
    
    @Published private(set) var btDevices: [BluetoothDevice] = []
    @Published private(set) var lanDevices: [LanDevice] = []
    @Published private(set) var scanDate: String = ""
    
    // MARK: - Init
    
    init(sessionId: UUID) {
        loadData(with: sessionId)
    }
    
    // MARK: - Methods
    
    private func loadData(with sessionId: UUID) {
        do {
            let session = try repository.fetchSession(by: sessionId)
            scanDate = session?.startedAt.formatted(date: .abbreviated, time: .standard) ?? ""
            btDevices = session?.bluetoothDevices ?? []
            lanDevices = session?.lanDevices ?? []
        } catch {
            print(error.localizedDescription)
        }
    }
}
