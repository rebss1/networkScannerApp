//
//  RealmRepository.swift
//  networkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import RealmSwift

final class RealmRepository: Repository {
    private let realm: Realm

    init(configuration: Realm.Configuration = .defaultConfiguration) throws {
        realm = try Realm(configuration: configuration)
    }

    func saveSession(startedAt: Date,
                     finishedAt: Date,
                     bluetooth: [BluetoothDevice],
                     lan: [LanHost]) throws {
        let session = RScanSession()
        session.startedAt = startedAt
        session.finishedAt = finishedAt

        let bt = bluetooth.map { d -> RDevice in
            let r = RDevice()
            r.kind = DeviceKind.bluetooth.rawValue
            r.name = d.name
            r.uuid = d.id.uuidString
            r.rssi = d.rssi
            r.status = d.state
            r.lastSeen = d.lastSeen
            return r
        }
        let ln = lan.map { h -> RDevice in
            let r = RDevice()
            r.kind = DeviceKind.lan.rawValue
            r.name = h.hostname
            r.ip   = h.ipAddress
            r.mac  = h.macAddress
            // LanHost has no lastSeen; RDevice.lastSeen keeps default
            return r
        }
        session.devices.append(objectsIn: bt + ln)

        try realm.write {
            realm.add(session, update: .modified)
        }
    }

    func fetchSessions(filterName: String?,
                       from: Date?,
                       to: Date?) throws -> [ScanSession] {
        var res = realm.objects(RScanSession.self)
            .sorted(byKeyPath: "startedAt", ascending: false)

        if let from { res = res.where { $0.startedAt >= from } }
        if let to   { res = res.where { $0.startedAt <= to   } }
        if let name = filterName, !name.isEmpty {
            res = res.where { $0.devices.name.contains(name, options: .caseInsensitive) }
        }

        return res.map { r in
            let bt: [BluetoothDevice] = Array(
                r.devices
                    .filter { $0.kind == DeviceKind.bluetooth.rawValue }
                    .map { d in
                        BluetoothDevice(
                            id: UUID(uuidString: d.uuid ?? UUID().uuidString) ?? UUID(),
                            name: d.name,
                            rssi: d.rssi,
                            state: d.status
                        )
                    }
            )
            let ln: [LanHost] = Array(
                r.devices
                    .filter { $0.kind == DeviceKind.lan.rawValue }
                    .map { d in
                        LanHost(
                            ipAddress: d.ip ?? "",
                            macAddress: d.mac,
                            hostname: d.name
                        )
                    }
            )
            return ScanSession(
                startedAt: r.startedAt,
                finishedAt: r.finishedAt,
                bluetoothDevices: bt,
                lanHosts: ln
            )
        }
    }
}
