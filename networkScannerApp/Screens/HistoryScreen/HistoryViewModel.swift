//
//  HistoryViewModel.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var sessions: [ScanSession] = []
    @Published var filterName: String = ""
    @Published var fromDate: Date? = nil
    @Published var toDate: Date? = nil

    private let repo: Repository

    init(repo: Repository = (try? RealmRepository()) ?? { fatalError("Realm init failed") }()) {
        self.repo = repo
        reload()
    }

    func reload() {
        do {
            sessions = try repo.fetchSessions(filterName: filterName, from: fromDate, to: toDate)
        } catch {
            print("History fetch error: \(error)")
        }
    }
}
