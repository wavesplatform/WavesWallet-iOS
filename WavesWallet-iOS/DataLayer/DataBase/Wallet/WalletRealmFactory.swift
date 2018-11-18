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
    case version_4 = 4 // BetaTest 2.0
    case version_5 = 5
}

fileprivate enum Constants {
    static let currentVersion: SchemaVersions = .version_5
    static let isHiddenKey: String = "isHidden"
    static let assetIdKey: String = "assetId"
    static let settingsKey: String = "settings"
    static let nameKey: String = "name"
}

enum WalletRealmFactory {

    static func create(accountAddress: String) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent("\(accountAddress).realm")
        config.schemaVersion = Constants.currentVersion.rawValue
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
                              DataTransaction.self,
                              DataTransactionData.self,
                              AnyTransaction.self,
                              UnrecognisedTransaction.self,
                              Asset.self,
                              AddressBook.self,
                              AssetBalance.self,
                              AssetBalanceSettings.self,
                              AccountEnvironment.self,
                              AccountSettings.self,
                              DexAsset.self,
                              DexAssetPair.self]

        config.migrationBlock = { migration, oldSchemaVersion in

            debug("Wallet Migration!!! \(oldSchemaVersion)")

            if oldSchemaVersion < SchemaVersions.version_4.rawValue {
                removeTransaction(migration: migration)
            }

            if oldSchemaVersion < SchemaVersions.version_5.rawValue {
                removeTransaction(migration: migration)

                migration.enumerateObjects(ofType: AssetBalance.className()) { oldObject, newObject in

                    guard let isHidden = oldObject?[Constants.isHiddenKey] as? Bool else { return }
                    guard var assetId = oldObject?[Constants.assetIdKey] as? String else { return }

                    assetId = assetId.count == 0 ? GlobalConstants.wavesAssetId : assetId

                    let assetBalanceSettings = migration.create(AssetBalanceSettings.className())
                    assetBalanceSettings[Constants.assetIdKey] = assetId
                    assetBalanceSettings[Constants.isHiddenKey] = isHidden
                    newObject?[Constants.settingsKey] = assetBalanceSettings
                    newObject?[Constants.assetIdKey] = assetId
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
        }

        return config
    }

    static func realm(accountAddress: String) throws -> Realm {
        let config = create(accountAddress: accountAddress)
        return try Realm(configuration: config)
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
    }
}
