//
//  WalletRealmConfig.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 23/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift
import WavesSDK
import WavesSDKExtensions
import DomainLayer

fileprivate enum SchemaVersions: UInt64 {
    case version_1 = 1 // Release old version
    case version_2 = 2 // Dev version   
    case version_4 = 4 // BetaTest 2.0rc0
    case version_5 = 5 // BetaTest 2.0rc1
    case version_2_0 = 6 // v2.0
    case version_2_0_2 = 7 // v2.0.2
    case version_2_1 = 8 // v2.1
    case version_2_2 = 11 // v2.2
    case version_2_3 = 12 // v2.3
    case version_2_4 = 13 // v2.4
    case version_2_5 = 14 // v2.5
    case version_2_6 = 15 // v2.9
    case version_2_11 = 17 // v2.11
    case version_2_12 = 19 // v2.12
    case version_2_12_1 = 20 // v2.12.1
    
    static let currentVersion: SchemaVersions = .version_2_12_1
}

fileprivate enum Constants {
    static let isHiddenKey: String = "isHidden"
    static let isSpamKey: String = "isSpam"
    static let assetIdKey: String = "assetId"
    static let settingsKey: String = "settings"
    static let nameKey: String = "name"
    static let sortLevel: String = "sortLevel"
    static let sortLevelNotFound: Float = -1
}

enum WalletRealmFactory {

    static func create(accountAddress: String) -> Realm.Configuration {
        var config = Realm.Configuration()
        
        config.fileURL = config.fileURL?.deletingLastPathComponent()

            .appendingPathComponent("\(accountAddress).realm")
        config.schemaVersion = SchemaVersions.currentVersion.rawValue
        config.objectTypes = [TransactionRealm.self,
                              IssueTransactionRealm.self,
                              TransferTransactionRealm.self,
                              ReissueTransactionRealm.self,
                              LeaseTransactionRealm.self,
                              LeaseCancelTransactionRealm.self,
                              AliasTransactionRealm.self,
                              MassTransferTransactionRealm.self,
                              MassTransferTransactionTransferRealm.self,
                              BurnTransactionRealm.self,
                              ExchangeTransactionRealm.self,
                              ExchangeTransactionOrderRealm.self,
                              ExchangeTransactionAssetPairRealm.self,
                              ScriptTransactionRealm.self,
                              AssetScriptTransactionRealm.self,
                              DataTransactionRealm.self,
                              DataTransactionDataRealm.self,
                              AnyTransactionRealm.self,
                              UnrecognisedTransactionRealm.self,
                              SponsorshipTransactionRealm.self,
                              InvokeScriptTransactionRealm.self,
                              InvokeScriptTransactionPaymentRealm.self,
                              AssetRealm.self,
                              AddressBook.self,
                              AssetBalanceRealm.self,
                              AssetBalanceSettingsRealm.self,
                              AccountEnvironment.self,
                              AccountSettings.self,
                              DexAsset.self,
                              DexAssetPair.self,
                              Alias.self]

        config.migrationBlock = { migration, oldSchemaVersion in

            SweetLogger.debug("Wallet Migration!!! \(oldSchemaVersion)")

            if oldSchemaVersion < SchemaVersions.version_2.rawValue {

                if migration.hadProperty(onType: AssetBalanceRealm.className(), property: Constants.isHiddenKey) &&
                    migration.hadProperty(onType: AssetBalanceRealm.className(), property: Constants.assetIdKey) &&
                    migration.hadProperty(onType: AssetBalanceRealm.className(), property: Constants.isSpamKey) {

                    migration.enumerateObjects(ofType: AssetBalanceRealm.className()) { oldObject, newObject in

                        guard let isHidden = oldObject?[Constants.isHiddenKey] as? Bool else { return }
                        guard var assetId = oldObject?[Constants.assetIdKey] as? String else { return }
                        guard let isSpam = oldObject?[Constants.isSpamKey] as? Bool else { return }

                        assetId = assetId.count == 0 ? WavesSDKConstants.wavesAssetId : assetId

                        let assetBalanceSettings = migration.create(AssetBalanceSettingsRealm.className())
                        assetBalanceSettings[Constants.assetIdKey] = assetId
                        assetBalanceSettings[Constants.isHiddenKey] = isHidden && !isSpam

                        //It current code for 2 Schema Version
                        if migration.hadProperty(onType: AssetBalanceRealm.className(), property: Constants.settingsKey) {
                            newObject?[Constants.settingsKey] = assetBalanceSettings
                        }

                        newObject?[Constants.assetIdKey] = assetId
                    }
                }

                migration.enumerateObjects(ofType: AddressBook.className()) { oldObject, newObject in

                    let name = oldObject?[Constants.nameKey] as? String

                    if let name = name {
                        newObject?[Constants.nameKey] = name
                    } else if let newObject = newObject {
                        migration.delete(newObject)
                    }
                }
            }

            if oldSchemaVersion < SchemaVersions.version_4.rawValue {
                removeTransaction(migration: migration)
            }

            if oldSchemaVersion < SchemaVersions.version_5.rawValue {
                removeTransaction(migration: migration)
            }

            if oldSchemaVersion < SchemaVersions.version_2_0.rawValue {
                removeTransaction(migration: migration)
            }

            if oldSchemaVersion < SchemaVersions.version_2_0_2.rawValue {
               resetAssetSort(migration: migration)
            }

            if oldSchemaVersion < SchemaVersions.version_2_1.rawValue {
                removeTransaction(migration: migration)
            }

            if oldSchemaVersion < SchemaVersions.version_2_2.rawValue {
                removeTransaction(migration: migration)
                removeAsset(migration: migration)
            }
            
            if oldSchemaVersion < SchemaVersions.version_2_3.rawValue {
                removeTransaction(migration: migration)
            }
            
            if oldSchemaVersion < SchemaVersions.version_2_4.rawValue {
                removeTransaction(migration: migration)
            }
            
            if oldSchemaVersion < SchemaVersions.version_2_5.rawValue {
                removeAsset(migration: migration)
                removeTransaction(migration: migration)
            }
            
            if oldSchemaVersion < SchemaVersions.version_2_6.rawValue {
                removeAsset(migration: migration)
            }
            
            if oldSchemaVersion < SchemaVersions.version_2_11.rawValue {
                                
                migration.enumerateObjects(ofType: "AssetBalanceSettings") { oldObject, newObject in
                                        
                    guard var assetId: String = oldObject?["assetId"] as? String else { return }
                    guard let sortLevel: Int64 = oldObject?["sortLevel"] as? Int64 else { return }
                    guard let isHidden: Bool = oldObject?["isHidden"] as? Bool else { return }
                    guard let isFavorite: Bool = oldObject?["isFavorite"] as? Bool else { return }
                     
                    assetId = assetId.count == 0 ? WavesSDKConstants.wavesAssetId : assetId

                    let assetBalanceSettings = migration.create(AssetBalanceSettingsRealm.className())
                    assetBalanceSettings["assetId"] = assetId
                    assetBalanceSettings["sortLevel"] = sortLevel
                    assetBalanceSettings["isHidden"] = isHidden
                    assetBalanceSettings["isFavorite"] = isFavorite
                }
            }
        }

        return config
    }

    static func realm(accountAddress: String) throws -> Realm {
        let config = create(accountAddress: accountAddress)
        return try Realm(configuration: config)
    }

    static func resetAssetSort(migration: Migration) {
        migration.enumerateObjects(ofType: AssetBalanceSettingsRealm.className()) { oldObject, newObject in
            newObject?[Constants.sortLevel] = Constants.sortLevelNotFound
        }
    }

    static func removeTransaction(migration: Migration) {
        migration.deleteData(forType: TransactionRealm.className())
        migration.deleteData(forType: IssueTransactionRealm.className())
        migration.deleteData(forType: TransferTransactionRealm.className())
        migration.deleteData(forType: ReissueTransactionRealm.className())
        migration.deleteData(forType: LeaseTransactionRealm.className())
        migration.deleteData(forType: LeaseCancelTransactionRealm.className())
        migration.deleteData(forType: AliasTransactionRealm.className())
        migration.deleteData(forType: MassTransferTransactionRealm.className())
        migration.deleteData(forType: MassTransferTransactionTransferRealm.className())
        migration.deleteData(forType: BurnTransactionRealm.className())
        migration.deleteData(forType: ExchangeTransactionRealm.className())
        migration.deleteData(forType: ExchangeTransactionOrderRealm.className())
        migration.deleteData(forType: ExchangeTransactionAssetPairRealm.className())
        migration.deleteData(forType: DataTransactionRealm.className())
        migration.deleteData(forType: DataTransactionDataRealm.className())
        migration.deleteData(forType: AnyTransactionRealm.className())
        migration.deleteData(forType: UnrecognisedTransactionRealm.className())
        migration.deleteData(forType: ScriptTransactionRealm.className())
        migration.deleteData(forType: AssetScriptTransactionRealm.className())
        migration.deleteData(forType: SponsorshipTransactionRealm.className())
        migration.deleteData(forType: InvokeScriptTransactionRealm.className())
        migration.deleteData(forType: InvokeScriptTransactionPaymentRealm.className())
    }
    
    static func removeAsset(migration: Migration) {
        migration.deleteData(forType: AssetRealm.className())
        migration.deleteData(forType: AssetBalanceRealm.className())        
    }
}

extension Migration {
    func hadProperty(onType typeName: String, property propertyName: String) -> Bool {
        var hasPropery = false
        self.enumerateObjects(ofType: typeName) { (oldObject, _) in
            hasPropery = oldObject?.objectSchema.properties.contains(where: { $0.name == propertyName }) ?? false
            return
        }
        return hasPropery
    }

    func renamePropertyIfExists(onType typeName: String, from oldName: String, to newName: String) {
        if (hadProperty(onType: typeName, property: oldName)) {
            renameProperty(onType: typeName, from: oldName, to: newName)
        }
    }
}
