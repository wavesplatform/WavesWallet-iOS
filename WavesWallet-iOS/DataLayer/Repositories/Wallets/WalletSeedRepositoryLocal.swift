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

    func seed(for address: String, publicKey: String, password: String) -> Observable<DomainLayer.DTO.WalletSeed> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            do {
                guard let realm = try self?.realm(address: address, password: password) else {
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

    func saveSeed(for walletSeed: DomainLayer.DTO.WalletSeed, password: String) -> Observable<DomainLayer.DTO.WalletSeed> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            do {
                guard let realm = try self?.realm(address: walletSeed.address, password: password) else {
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

    func changePassword(for address: String, publicKey: String, oldPassword: String, newPassword: String) -> Observable<DomainLayer.DTO.WalletSeed> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let owner = self else {
                observer.onError(WalletSeedRepositoryError.fail)
                return Disposables.create()
            }

            do {
                guard let realm = try owner.realm(address: address, password: oldPassword) else {
                    observer.onError(WalletSeedRepositoryError.fail)
                    return Disposables.create()
                }

                if let object = realm.object(ofType: SeedItem.self, forPrimaryKey: publicKey) {

                    if owner.removeDB(realm: realm) {
                        observer.onNext(DomainLayer.DTO.WalletSeed(seed: object))
                        observer.onCompleted()
                    } else {
                        observer.onError(WalletSeedRepositoryError.fail)
                    }
                } else {
                    observer.onError(WalletSeedRepositoryError.fail)
                }

            } catch let error {
                observer.onError(error)
            }

            return Disposables.create()
        })
        .flatMap({ [weak self] seed -> Observable<DomainLayer.DTO.WalletSeed> in
            return self?.saveSeed(for: seed, password: newPassword) ?? Observable.error(WalletSeedRepositoryError.fail)
        })
    }

    func deleteSeed(for address: String) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            if self?.removeDB(address: address) ?? false {
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

    func removeDB(address: String) -> Bool {

        guard let fileURL = try? Realm().configuration.fileURL else {
            error("File Realm is nil")
            return false
        }

        guard let path = fileURL?
            .deletingLastPathComponent()
            .appendingPathComponent("\(address)_seed.realm") else { return false }

        do {
            try FileManager.default.removeItem(at: path)
            return true
        } catch _ {
            return false
        }
    }

    func removeDB(realm: Realm) -> Bool {
        guard let fileURL = realm.configuration.fileURL else {
            error("File Realm is nil")
            return false
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch _ {
            return false
        }
    }


    func realmConfig(address: String,
                           password: String) -> Realm.Configuration? {

        var config = Realm.Configuration(encryptionKey: Data(bytes: Hash.sha512(Array(password.utf8))))
        config.objectTypes = [SeedItem.self]
        config.schemaVersion = UInt64(Constants.schemaVersion)

        guard let fileURL = config.fileURL else {
            error("File Realm is nil")
            return nil
        }

        config.fileURL = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(address)_seed.realm")

        config.migrationBlock = { _, oldSchemaVersion in
            debug("Migration!!! \(oldSchemaVersion)")
        }
        return config
    }

    func realm(address: String,
               password: String) throws -> Realm? {

        guard let config = realmConfig(address: address,
                                       password: password) else { return nil }

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

        } catch _ {
            throw WalletSeedRepositoryError.fail
        }
    }
}
