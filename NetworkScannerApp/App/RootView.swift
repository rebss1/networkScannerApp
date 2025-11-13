//
//  RootView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ScanView()
                .tabItem {
                    Label("Сканирование", systemImage: "dot.radiowaves.left.and.right")
                }
            
            HistoryView()
                .tabItem {
                    Label("История", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}
