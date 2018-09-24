//
//  WalletsRepository.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

private enum Constants {
    static let schemaVersion: UInt64 = 2
}

final class WalletsRepositoryLocal: WalletsRepositoryProtocol {

    private let environment: Environment

    init(environment: Environment) {
        self.environment = environment
    }

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let realm = self?.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(WalletItem.self)
                .toArray()
                .map { DomainLayer.DTO.Wallet(wallet: $0) }

            observer.onNext(objects)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    func wallet(by publicKey: String) -> Observable<DomainLayer.DTO.Wallet> {

        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? Realm() else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            if let object = realm.object(ofType: WalletItem.self, forPrimaryKey: publicKey) {
                observer.onNext(.init(wallet: object))
                observer.onCompleted()
            } else {
                observer.onError(WalletsRepositoryError.fail)
            }

            return Disposables.create()
        })
    }

    func saveWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let realm = self?.realm else {                
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.add(WalletItem(wallet: wallet), update: true)
                }
                observer.onNext(wallet)
                observer.onCompleted()
            } catch _ {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }

    func removeWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let realm = self?.realm else {
                observer.onNext(false)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            do {
                if let object = realm.object(ofType: WalletItem.self, forPrimaryKey: wallet.publicKey) {
                    try realm.write {
                        realm.delete(object)
                    }
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onError(WalletsRepositoryError.fail)
                }
            } catch _ {
                observer.onNext(false)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }
}

private extension WalletsRepositoryLocal {

    func getWalletsConfig(environment: Environment) -> Realm.Configuration? {

        var config = Realm.Configuration()
        config.schemaVersion = UInt64(Constants.schemaVersion)

        guard let fileURL = config.fileURL else {
            error("File Realm is nil")
            return nil
        }

        config.fileURL = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("wallets_\(environment.scheme).realm")

        config.migrationBlock = { _, oldSchemaVersion in
            debug("Migration!!! \(oldSchemaVersion)")
        }

        return config
    }

    var realm: Realm? {
        guard let config = getWalletsConfig(environment: environment) else {
            error("Realm Configuration is nil")
            return nil
        }

        let realm = try? Realm(configuration: config)
        return realm
    }
}
