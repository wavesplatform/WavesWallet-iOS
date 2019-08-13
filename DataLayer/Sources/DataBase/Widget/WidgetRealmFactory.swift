//
//  SeedRealmFactory.swift
//  DataLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift
import WavesSDK
import WavesSDKExtensions
import DomainLayer

fileprivate enum SchemaVersions: UInt64 {
    case version_2_5 = 1
    static let currentVersion: SchemaVersions = .version_2_5
}


enum WidgetRealmFactory {
    
    private static func config(chainId: String) -> Realm.Configuration {
        
        var config = Realm.Configuration()
        config.objectTypes = [WidgetSettings.self, WidgetSettingsAsset.self, WidgetSettingsAssetIcon.self]
        config.schemaVersion = UInt64(SchemaVersions.currentVersion.rawValue)
        
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.wavesplatform")!
            .appendingPathComponent("widget_\(chainId).realm")
        
        config.fileURL = fileURL
        
        config.migrationBlock = { migration, oldSchemaVersion in
            SweetLogger.debug("Migration!!! \(oldSchemaVersion)")
        }
        
        return config
    }
    
    static func realm(chainId: String) -> Realm? {
        return try? Realm(configuration: config(chainId: chainId))
    }
}

