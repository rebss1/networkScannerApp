//
//  RScanSession.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import RealmSwift

final class RScanSession: Object {
    @Persisted(primaryKey: true) var id = UUID()
    @Persisted var startedAt: Date = .init()
    @Persisted var finishedAt: Date = .init()
    @Persisted var devices = List<RDevice>()
}
