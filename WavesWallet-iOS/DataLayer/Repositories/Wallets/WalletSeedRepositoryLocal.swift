//
//  WalletSeedRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

fileprivate enum Constants {
    static let schemaVersion: UInt64 = 2
}

final class WalletSeedRepositoryLocal: WalletSeedRepositoryProtocol {

    func seed(for address: String, publicKey: String, seedId: String, password: String) -> Observable<DomainLayer.DTO.WalletSeed> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            do {
                guard let realm = try self?.realm(address: address, seedId: seedId, password: password) else {
                    observer.onError(WalletSeedRepositoryError.fail)
                    return Disposables.create()
                }

                
                if let object = realm.object(ofType: SeedItem.self, forPrimaryKey: publicKey) {
                    observer.onNext(DomainLayer.DTO.WalletSeed(seed: object))
                    observer.onCompleted()
                } else {
                    observer.onError(WalletSeedRepositoryError.fail)
                }

            } catch let error {
                observer.onError(error)
            }

            return Disposables.create()
        })
    }

    func saveSeed(for walletSeed: DomainLayer.DTO.WalletSeed, seedId: String, password: String) -> Observable<DomainLayer.DTO.WalletSeed> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            do {
                guard let realm = try self?.realm(address: walletSeed.address, seedId: seedId, password: password) else {
                    observer.onError(WalletSeedRepositoryError.fail)
                    return Disposables.create()
                }

                do {
                    try realm.write {
                        realm.add(SeedItem.init(seed: walletSeed), update: true)
                    }
                    observer.onNext(walletSeed)
                    observer.onCompleted()
                } catch _ {
                    observer.onError(WalletSeedRepositoryError.fail)
                }

            } catch let error {
                observer.onError(error)
            }

            return Disposables.create()
        })
    }

    func deleteSeed(for address: String, seedId: String) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            if self?.removeDB(address: address, seedId: seedId) ?? false {
                observer.onNext(true)
                observer.onCompleted()
            } else {
                observer.onError(WalletSeedRepositoryError.fail)
            }

            return Disposables.create()
        })
    }
}

// MARK: Realm
private extension WalletSeedRepositoryLocal {

    func removeDB(address: String, seedId: String) -> Bool {

        guard let fileURL = Realm.Configuration.defaultConfiguration.fileURL else {
            error("File Realm is nil")
            return false
        }

        let path = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(address)_seed_\(seedId).realm")

        let oldPath = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(address)_seed.realm")

        do {
            try FileManager.default.removeItem(at: path)
            try? FileManager.default.removeItem(at: oldPath)
            return true
        } catch _ {
            return false
        }
    }

    func realmConfig(address: String,
                     password: String,
                     seedId: String) -> Realm.Configuration? {

        var config = Realm.Configuration(encryptionKey: Data(bytes: Hash.sha512(Array(password.utf8))))
        config.objectTypes = [SeedItem.self]
        config.schemaVersion = UInt64(Constants.schemaVersion)

        guard let fileURL = config.fileURL else {
            error("File Realm is nil")
            return nil
        }

        config.fileURL = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(address)_seed_\(seedId).realm")

        config.migrationBlock = { _, oldSchemaVersion in
            debug("Migration!!! \(oldSchemaVersion)")
        }
        return config
    }

    func realm(address: String,
               seedId: String,
               password: String) throws -> Realm? {

        if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {

            let oldUrl = fileURL
                .deletingLastPathComponent()
                .appendingPathComponent("\(address)_seed.realm")
            
            let newUrl = fileURL
                .deletingLastPathComponent()
                .appendingPathComponent("\(address)_seed_\(seedId).realm")

            do {
                if FileManager.default.fileExists(atPath: oldUrl.absoluteString) == true
                    && FileManager.default.fileExists(atPath: newUrl.absoluteString) == false {
                    try FileManager.default.moveItem(at: oldUrl, to: newUrl)
                }
            } catch let e {
                error(e)
            }
        }

        guard let config = realmConfig(address: address,
                                       password: password,
                                       seedId: seedId) else { return nil }

        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch let error as Realm.Error {

            switch error {
            case Realm.Error.fileAccess, Realm.Error.filePermissionDenied:
                throw WalletSeedRepositoryError.permissionDenied

            default:
                throw WalletSeedRepositoryError.fail
            }

        } catch let e {
            error(e)
            throw WalletSeedRepositoryError.fail
        }
    }
}
