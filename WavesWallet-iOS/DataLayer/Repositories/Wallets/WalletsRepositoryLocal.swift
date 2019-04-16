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
import WavesSDKExtension

final class WalletsRepositoryLocal: WalletsRepositoryProtocol {

    func wallets() -> Observable<[DomainLayer.DTO.Wallet]> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
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

        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }
            
            guard let realm = self.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }
            
            if let object = realm.object(ofType: WalletItem.self, forPrimaryKey: publicKey) {
                observer.onNext(.init(wallet: object))
                observer.onCompleted()
            } else {
                observer.onError(WalletsRepositoryError.notFound)
                SweetLogger.error(WalletsRepositoryError.notFound)
            }

            return Disposables.create()
        })
    }

    func walletEncryption(by publicKey: String) -> Observable<DomainLayer.DTO.WalletEncryption> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            if let object = realm.object(ofType: WalletEncryption.self, forPrimaryKey: publicKey) {
                observer.onNext(.init(wallet: object))
                observer.onCompleted()
            } else {
                observer.onError(WalletsRepositoryError.notFound)
            }

            return Disposables.create()
        })
    }

    func saveWalletEncryption(_ walletEncryption: DomainLayer.DTO.WalletEncryption) -> Observable<DomainLayer.DTO.WalletEncryption> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.add(WalletEncryption(wallet: walletEncryption), update: true)
                }
                observer.onNext(walletEncryption)
                observer.onCompleted()
            } catch let error {
                SweetLogger.error(error)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }

    func removeWalletEncryption(by publicKey: String) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onNext(false)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            do {
                if let object = realm.object(ofType: WalletEncryption.self, forPrimaryKey: publicKey) {
                    try realm.write {
                        realm.delete(object)
                    }
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onError(WalletsRepositoryError.fail)
                }
            } catch let error {
                SweetLogger.error(error)
                observer.onNext(false)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }
    

    func saveWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<DomainLayer.DTO.Wallet> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.add(WalletItem(wallet: wallet), update: true)
                }
                observer.onNext(wallet)
                observer.onCompleted()
            } catch let error {
                SweetLogger.error(error)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }

    func saveWallets(_ wallets: [DomainLayer.DTO.Wallet]) -> Observable<[DomainLayer.DTO.Wallet]> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    let walletItems = wallets.map { WalletItem(wallet: $0) }
                    realm.add(walletItems, update: true)
                }
                observer.onNext(wallets)
                observer.onCompleted()
            } catch let error {
                SweetLogger.error(error)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }

    func removeWallet(_ wallet: DomainLayer.DTO.Wallet) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
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
                    observer.onError(WalletsRepositoryError.notFound)                    
                    SweetLogger.error(WalletsRepositoryError.notFound)
                }
            } catch let error {
                SweetLogger.error(error)
                observer.onNext(false)
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }

    func wallets(specifications: WalletsRepositorySpecifications) -> Observable<[DomainLayer.DTO.Wallet]> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(WalletItem.self)
                .filter("isLoggedIn == %@", specifications.isLoggedIn)
                .toArray()
                .map { DomainLayer.DTO.Wallet(wallet: $0) }

            observer.onNext(objects)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    func listenerWallet(by publicKey: String) -> Observable<DomainLayer.DTO.Wallet> {

        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let self = self else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(WalletsRepositoryError.fail)
                return Disposables.create()
            }

            let result = realm.objects(WalletItem.self)

            let collection = Observable.collection(from: result)
            let disposable = collection.flatMap({ items -> Observable<DomainLayer.DTO.Wallet> in
                if let item = items.toArray().first(where: { $0.publicKey == publicKey }) {
                     return Observable.just(DomainLayer.DTO.Wallet(wallet: item))
                }
                return Observable.empty()
            })
            .bind(to: observer)
            return Disposables.create([disposable])
        })
    }
}

private extension WalletsRepositoryLocal {

    var realm: Realm? {
        guard let config = WalletRealmFactory.Configuration.walletsConfig else {
            SweetLogger.error("Realm Configuration is nil")
            return nil
        }

        let realm = try? Realm(configuration: config)
        return realm
    }
}
