//
//  ScanCircleView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import SwiftUI

struct ScanCircleView: View {
    let isScanning: Bool
    let size: CGFloat = 180

    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Основной круг
            Circle()
                .fill(Color.accentColor.opacity(isScanning ? 0.9 : 1.0))
                .frame(width: size, height: size)

            // Пульсирующая волна
            if isScanning {
                Circle()
                    .fill(Color.accentColor.opacity(0.35))
                    .frame(width: size, height: size)
                    .scaleEffect(animate ? 1.35 : 0.85)
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 1.1)
                            .repeatForever(autoreverses: false),
                        value: animate
                    )
            }

            // ИКОНКА в центре
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 4)
        }
        .onAppear {
            if isScanning { animate = true }
        }
        .onChange(of: isScanning) { newValue in
            animate = newValue
        }
    }
}
