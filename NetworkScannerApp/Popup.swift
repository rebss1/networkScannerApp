//
//  Popup.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import Foundation
import SwiftMessages
import SwiftUI
import UIKit

@MainActor
final class Popup {
    
    // MARK: - Public
    
    static func showAlert(
        title: String = "",
        message: String,
        buttonTitle: String = "ОК",
        onTap: (() -> Void)? = nil
    ) {
        let alertView = PopupAlertView(
            title: title,
            message: message,
            primaryTitle: buttonTitle,
            secondaryTitle: nil,
            onPrimary: onTap,
            onDismiss: { SwiftMessages.hide() }
        ).padding()
        
        let view = MessageHostingView(
            id: "alert-\(UUID().uuidString)",
            content: alertView
        )

        var config = defaultCenterConfig()
        config.duration = .forever
        config.interactiveHide = true
        SwiftMessages.show(config: config, view: view)
    }
    
    static func showConfirm(
        title: String = "",
        message: String,
        yesTitle: String = "Да",
        noTitle: String = "Нет",
        onYes: @escaping () -> Void
    ) {
        let alertView = PopupAlertView(
            title: title,
            message: message,
            primaryTitle: yesTitle,
            secondaryTitle: noTitle,
            onPrimary: onYes,
            onDismiss: { SwiftMessages.hide() }
        ).padding()
        
        let view = MessageHostingView(
            id: "confirm-\(UUID().uuidString)",
            content: alertView
        )

        var config = defaultCenterConfig()
        config.duration = .forever
        config.interactiveHide = true
        SwiftMessages.show(config: config, view: view)
    }
    
    static func show<Content: View>(
            id: String = UUID().uuidString,
            config: SwiftMessages.Config? = nil,
            @ViewBuilder content: () -> Content
    ) {
        let hosting = MessageHostingView(
            id: id,
            content: content()
        )
        
        var cfg = config ?? defaultCenterConfig()
        cfg.duration = .forever
        cfg.interactiveHide = true
        
        SwiftMessages.show(config: cfg, view: hosting)
    }
    
    static func hide() {
        SwiftMessages.hide()
    }
    
    // MARK: - Private
    
    private static func defaultCenterConfig() -> SwiftMessages.Config {
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.presentationContext = .window(windowLevel: .normal)
        config.dimMode = .color(
            color: UIColor.black.withAlphaComponent(0.35),
            interactive: true
        )
        config.interactiveHide = true
        return config
    }
}
