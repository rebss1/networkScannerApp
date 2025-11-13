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
    
    @LazyInjected(\.repository) private var repository
    
    @Published private(set) var sessions: [ScanSession] = []
    @Published private(set) var filterName: String = ""
    @Published private(set) var fromDate: Date?
    @Published private(set) var toDate: Date?
    
    // MARK: - Methods
    
    func loadData() {
        do {
            let result = try repository.fetchSessions(
                filterName: filterName,
                from: fromDate,
                to: toDate
            )
            sessions = result
        } catch {
            print("History fetch error: \(error)")
        }
    }
}
