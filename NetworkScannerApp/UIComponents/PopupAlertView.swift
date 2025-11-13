//
//  PopupAlertView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import SwiftUI

struct PopupAlertView: View {
    
    // MARK: - Properties
    
    let title: String
    let message: String
    let primaryTitle: String
    let secondaryTitle: String?
    let onPrimary: (() -> Void)?
    let onDismiss: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            actionsView
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 38)
                .fill(.ultraThinMaterial)
        }
        .shadow(color: Color.black.opacity(0.15), radius: 20, y: 4)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var actionsView: some View {
        if let secondaryTitle {
            HStack(spacing: 12) {
                Button {
                    onDismiss()
                } label: {
                    Text(secondaryTitle)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.thinMaterial)
                        )
                }
                
                Button {
                    onDismiss()
                    onPrimary?()
                } label: {
                    Text(primaryTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.accentColor)
                        )
                }
            }
        } else {
            Button {
                onDismiss()
                onPrimary?()
            } label: {
                Text(primaryTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.accentColor)
                    )
            }
        }
    }
}
