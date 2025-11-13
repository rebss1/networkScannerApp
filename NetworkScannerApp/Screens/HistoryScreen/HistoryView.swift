//
//  HistoryView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct HistoryView: View {
    
    // MARK: - Properties

    @StateObject private var viewModel = HistoryViewModel()

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(viewModel.sessions) { session in
                        NavigationLink {
                            DevicesListView(sessionId: session.id)
                        } label: {
                            SessionView(session: session)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.large)
            .onAppear(perform: viewModel.loadData)
        }
    }
}
