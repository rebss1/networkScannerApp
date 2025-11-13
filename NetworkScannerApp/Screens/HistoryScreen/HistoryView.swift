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
    @State private var selectedSessionId: UUID?
    @State private var showDevices: Bool = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(viewModel.sessions) { session in
                        SessionView(session: session)
                            .onTapGesture {
                                selectedSessionId = session.id
                                showDevices = true
                            }
                    }
                }
                .padding()
                
                NavigationLink(
                    isActive: $showDevices,
                    destination: {
                        if let id = selectedSessionId {
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
            .navigationTitle("История")
            .navigationBarTitleDisplayMode(.large)
            .onAppear(perform: viewModel.loadData)
        }
    }
}
