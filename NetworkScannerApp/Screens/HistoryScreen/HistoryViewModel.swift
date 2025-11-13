//
//  HistoryViewModel.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI
import Combine
import FactoryKit

@MainActor
final class HistoryViewModel: ObservableObject {
    
    // MARK: - Properties

    @Injected(\.repository) private var repository: Repository
    
    @Published var sessions: [ScanSession] = []
    @Published var filterName: String = ""
    @Published var fromDate: Date?
    @Published var toDate: Date?

    // MARK: - Methods

    func loadData() {
        do {
            sessions = try repository.fetchSessions(
                filterName: filterName,
                from: fromDate,
                to: toDate
            )
        } catch {
            print("History fetch error: \(error)")
        }
    }
}
