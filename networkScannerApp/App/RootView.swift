//
//  RootView.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ScanScreen()
                .tabItem { Label("Сканирование", systemImage: "dot.radiowaves.left.and.right") }

            HistoryScreen()
                .tabItem { Label("История", systemImage: "clock.arrow.circlepath") }
        }
    }
}
