//
//  RealmRepository.swift
//  NetworkScannerApp
//
//  Created by Илья Лощилов on 12.11.2025.
//

import Foundation
import RealmSwift
import FactoryKit

final class RealmRepository: Repository {
    
    // MARK: - Properties
    
    private let configuration: Realm.Configuration

    // MARK: - Init

    init(configuration: Realm.Configuration = .defaultConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Methods
    
    private func makeRealm() throws -> Realm {
        if let realm = try? Realm(configuration: configuration) {
            return realm
        }
        
        print("⚠️ Realm init failed. Switching to in-memory Realm.")
        
        let fallback = Realm.Configuration(inMemoryIdentifier: "fallback")
        if let realm = try? Realm(configuration: fallback) {
            return realm
        }
        
        let uniqueFallback = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
        if let realm = try? Realm(configuration: uniqueFallback) {
            return realm
        }
        
        fatalError("❌ Unable to initialize Realm even with fallbacks.")
    }
    
    func saveSession(
        startedAt: Date,
        finishedAt: Date,
        bluetooth: [BluetoothDevice],
        lan: [LanDevice]
    ) throws -> UUID {
        let realm = try makeRealm()
        
        let session = RScanSession()
        session.startedAt = startedAt
        session.finishedAt = finishedAt
        
        let btDevices = bluetooth.map { device -> RDevice in
            let rDevice = RDevice()
            rDevice.kind = DeviceType.bluetooth.rawValue
            rDevice.name = device.name
            rDevice.uuid = device.id.uuidString
            rDevice.rssi = device.rssi
            rDevice.status = device.state
            rDevice.lastSeen = device.lastSeen
            return rDevice
        }
        let lanDevices = lan.map { device -> RDevice in
            let rDevice = RDevice()
            rDevice.kind = DeviceType.lan.rawValue
            rDevice.name = device.hostname
            rDevice.ip = device.ipAddress
            rDevice.mac = device.macAddress
            return rDevice
        }
        session.devices.append(objectsIn: btDevices + lanDevices)
        
        try realm.write {
            realm.add(session, update: .modified)
        }
        
        return session.id
    }
    
    func fetchSessions(
        filterName: String?,
        from: Date?,
        to: Date?
    ) throws -> [ScanSession] {
        let realm = try makeRealm()
        
        var sessions = realm.objects(RScanSession.self)
            .sorted(byKeyPath: "startedAt", ascending: false)

        if let from {
            sessions = sessions.where { $0.startedAt >= from }
        }
        if let to {
            sessions = sessions.where { $0.startedAt <= to }
        }
        if let name = filterName, !name.isEmpty {
            sessions = sessions.where { $0.devices.name.contains(name, options: .caseInsensitive) }
        }

        return sessions.map { session in
            let btDevices: [BluetoothDevice] = Array(
                session.devices
                    .filter { $0.kind == DeviceType.bluetooth.rawValue }
                    .map { device in
                        BluetoothDevice(
                            id: device.id,
                            name: device.name,
                            rssi: device.rssi,
                            state: device.status
                        )
                    }
            )
            let lanDevices: [LanDevice] = Array(
                session.devices
                    .filter { $0.kind == DeviceType.lan.rawValue }
                    .map { device in
                        LanDevice(
                            id: device.id,
                            ipAddress: device.ip ?? "",
                            macAddress: device.mac,
                            hostname: device.name
                        )
                    }
            )
            return ScanSession(
                id: session.id,
                startedAt: session.startedAt,
                finishedAt: session.finishedAt,
                bluetoothDevices: btDevices,
                lanDevices: lanDevices
            )
        }
    }
    
    func fetchSession(by id: UUID) throws -> ScanSession? {
        let realm = try makeRealm()
        
        guard let rSession = realm.object(ofType: RScanSession.self, forPrimaryKey: id) else {
            return nil
        }

        let btDevices: [BluetoothDevice] = Array(
            rSession.devices
                .filter { $0.kind == DeviceType.bluetooth.rawValue }
                .map { device in
                    BluetoothDevice(
                        id: device.id,
                        name: device.name,
                        rssi: device.rssi,
                        state: device.status
                    )
                }
        )

        let lanDevices: [LanDevice] = Array(
            rSession.devices
                .filter { $0.kind == DeviceType.lan.rawValue }
                .map { device in
                    LanDevice(
                        id: device.id,
                        ipAddress: device.ip ?? "",
                        macAddress: device.mac,
                        hostname: device.name
                    )
                }
        )

        return ScanSession(
            id: rSession.id,
            startedAt: rSession.startedAt,
            finishedAt: rSession.finishedAt,
            bluetoothDevices: btDevices,
            lanDevices: lanDevices
        )
    }
}

extension Container {
    var repository: Factory<Repository> {
        self { RealmRepository() }.cached
    }
}
