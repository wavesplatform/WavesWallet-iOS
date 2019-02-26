//
//  WalletRealmConfig.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 23/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

fileprivate enum SchemaVersions: UInt64 {
    case version_1 = 1 // Release old version
    case version_2 = 2 // Dev version
    case version_4 = 4 // BetaTest 2.0rc0
    case version_5 = 5 // BetaTest 2.0rc1
    case version_2_0 = 6 // v2.0
    case version_2_0_2 = 7 // v2.0.2
    case version_2_1 = 8 // v2.1
    case version_2_2 = 11 // v2.2

    static let currentVersion: SchemaVersions = .version_2_2
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
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(accountAddress).realm")
        config.schemaVersion = SchemaVersions.currentVersion.rawValue
        config.objectTypes = [Transaction.self,
                              IssueTransaction.self,
                              TransferTransaction.self,
                              ReissueTransaction.self,
                              LeaseTransaction.self,
                              LeaseCancelTransaction.self,
                              AliasTransaction.self,
                              MassTransferTransaction.self,
                              MassTransferTransactionTransfer.self,
                              BurnTransaction.self,
                              ExchangeTransaction.self,
                              ExchangeTransactionOrder.self,
                              ExchangeTransactionAssetPair.self,
                              ScriptTransaction.self,
                              AssetScriptTransaction.self,
                              DataTransaction.self,
                              DataTransactionData.self,
                              AnyTransaction.self,
                              UnrecognisedTransaction.self,
                              SponsorshipTransaction.self,
                              Asset.self,
                              AddressBook.self,
                              AssetBalance.self,
                              AssetBalanceSettings.self,
                              AccountEnvironment.self,
                              AccountSettings.self,
                              DexAsset.self,
                              DexAssetPair.self,
                              Alias.self]

        config.migrationBlock = { migration, oldSchemaVersion in

            SweetLogger.debug("Wallet Migration!!! \(oldSchemaVersion)")

            if oldSchemaVersion < SchemaVersions.version_2.rawValue {

                if migration.hadProperty(onType: AssetBalance.className(), property: Constants.isHiddenKey) &&
                    migration.hadProperty(onType: AssetBalance.className(), property: Constants.assetIdKey) &&
                    migration.hadProperty(onType: AssetBalance.className(), property: Constants.isSpamKey) {

                    migration.enumerateObjects(ofType: AssetBalance.className()) { oldObject, newObject in

                        guard let isHidden = oldObject?[Constants.isHiddenKey] as? Bool else { return }
                        guard var assetId = oldObject?[Constants.assetIdKey] as? String else { return }
                        guard let isSpam = oldObject?[Constants.isSpamKey] as? Bool else { return }

                        assetId = assetId.count == 0 ? GlobalConstants.wavesAssetId : assetId

                        let assetBalanceSettings = migration.create(AssetBalanceSettings.className())
                        assetBalanceSettings[Constants.assetIdKey] = assetId
                        assetBalanceSettings[Constants.isHiddenKey] = isHidden && !isSpam

                        //It current code for 2 Schema Version
                        if migration.hadProperty(onType: AssetBalance.className(), property: Constants.settingsKey) {
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
        }

        return config
    }

    static func realm(accountAddress: String) throws -> Realm {
        let config = create(accountAddress: accountAddress)
        return try Realm(configuration: config)
    }

    static func resetAssetSort(migration: Migration) {
        migration.enumerateObjects(ofType: AssetBalanceSettings.className()) { oldObject, newObject in
            newObject?[Constants.sortLevel] = Constants.sortLevelNotFound
        }
    }

    static func removeTransaction(migration: Migration) {
        migration.deleteData(forType: Transaction.className())
        migration.deleteData(forType: IssueTransaction.className())
        migration.deleteData(forType: TransferTransaction.className())
        migration.deleteData(forType: ReissueTransaction.className())
        migration.deleteData(forType: LeaseTransaction.className())
        migration.deleteData(forType: LeaseCancelTransaction.className())
        migration.deleteData(forType: AliasTransaction.className())
        migration.deleteData(forType: MassTransferTransaction.className())
        migration.deleteData(forType: MassTransferTransactionTransfer.className())
        migration.deleteData(forType: BurnTransaction.className())
        migration.deleteData(forType: ExchangeTransaction.className())
        migration.deleteData(forType: ExchangeTransactionOrder.className())
        migration.deleteData(forType: ExchangeTransactionAssetPair.className())
        migration.deleteData(forType: DataTransaction.className())
        migration.deleteData(forType: DataTransactionData.className())
        migration.deleteData(forType: AnyTransaction.className())
        migration.deleteData(forType: UnrecognisedTransaction.className())
        migration.deleteData(forType: ScriptTransaction.className())
        migration.deleteData(forType: AssetScriptTransaction.className())
        migration.deleteData(forType: SponsorshipTransaction.className())
    }
    
    static func removeAsset(migration: Migration) {
        migration.deleteData(forType: Asset.className())
        migration.deleteData(forType: AssetBalance.className())        
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
