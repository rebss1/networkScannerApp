//
//  SessionView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct SessionView: View {
    
    // MARK: - Properties

    private let session: ScanSession
    
    // MARK: - Body

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.startedAt.formatted(date: .abbreviated, time: .standard))
                    .font(.headline)
                
                Text("BT: \(session.bluetoothDevices.count) • LAN: \(session.lanDevices.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 38)
                .fill(.ultraThinMaterial)
        }
    }
    
    // MARK: - Init

    init(session: ScanSession) {
        self.session = session
    }
}
