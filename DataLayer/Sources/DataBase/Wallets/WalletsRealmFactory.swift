//
//  WalletsRealmFactory.swift
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
    case version_2_5 = 7    
    static let currentVersion: SchemaVersions = .version_2_5
}


enum WalletsRealmFactory {
    
    static var walletsConfig: Realm.Configuration? {
        
        var config = Realm.Configuration()
        config.objectTypes = [WalletEncryption.self, WalletItem.self]
        config.schemaVersion = UInt64(SchemaVersions.currentVersion.rawValue)
        
        guard let fileURL = config.fileURL else {
            SweetLogger.error("File Realm is nil")
            return nil
        }
        
        config.fileURL = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("wallets_\(WalletEnvironment.current.scheme).realm")
        
        config.migrationBlock = { migration, oldSchemaVersion in
            
            migration.enumerateObjects(ofType: WalletItem.className()) { _ , newObject in
                
                newObject?[WalletItem.isNeedShowWalletCleanBannerKey] = true
            }
            
            SweetLogger.debug("Migration!!! \(oldSchemaVersion)")
        }
        
        return config
    }
}
