//
//  NetworkHelper.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 13.11.2025.
//

import Network

enum NetworkHelper {
    static var isWiFiEnabled: Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "wifi-check")

        var result = false
        monitor.pathUpdateHandler = { path in
            result = path.usesInterfaceType(.wifi)
            monitor.cancel()
        }
        monitor.start(queue: queue)

        usleep(50_000)

        return result
    }
}
