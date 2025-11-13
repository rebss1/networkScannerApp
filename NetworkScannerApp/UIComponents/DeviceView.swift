//
//  DeviceView.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import SwiftUI

struct DeviceView: View {
    
    // MARK: - Properties

    private let iconName: String
    private let title: String?
    private let subtitle: String

    // MARK: - Body

    var body: some View {
        HStack {
            Image(systemName: iconName)

            VStack(alignment: .leading, spacing: 4) {
                Text(title ?? "Неизвестное устройство")
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 38)
                .fill(.ultraThinMaterial)
        }
    }
    
    // MARK: - Init

    init(iconName: String, title: String?, subtitle: String) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
    }
}
