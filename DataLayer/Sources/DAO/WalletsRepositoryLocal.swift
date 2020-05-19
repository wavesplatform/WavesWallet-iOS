//
//  WalletsRepository.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RealmSwift
import RxCocoa
import RxSwift
import WavesSDKExtensions

final class WalletsRepositoryLocal: WalletsRepositoryProtocol {
    private var environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func wallets() -> Observable<[Wallet]> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(WalletItem.self)
                .toArray()
                .map { Wallet(wallet: $0) }

            observer.onNext(objects)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func wallet(by publicKey: String) -> Observable<Wallet> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            if let object = realm.object(ofType: WalletItem.self, forPrimaryKey: publicKey) {
                observer.onNext(.init(wallet: object))
                observer.onCompleted()
            } else {
                observer.onError(RepositoryError.notFound)
                SweetLogger.error(RepositoryError.notFound)
            }

            return Disposables.create()
        }
    }

    func walletEncryption(by publicKey: String) -> Observable<WalletEncryption> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            if let object = realm.object(ofType: WalletEncryptionRealm.self, forPrimaryKey: publicKey) {
                observer.onNext(.init(wallet: object))
                observer.onCompleted()
            } else {
                observer.onError(RepositoryError.notFound)
            }

            return Disposables.create()
        }
    }

    func saveWalletEncryption(_ walletEncryption: WalletEncryption) -> Observable<WalletEncryption> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.add(WalletEncryptionRealm(wallet: walletEncryption), update: .all)
                }
                observer.onNext(walletEncryption)
                observer.onCompleted()
            } catch {
                SweetLogger.error(error)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func removeWalletEncryption(by publicKey: String) -> Observable<Bool> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onNext(false)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                if let object = realm.object(ofType: WalletEncryptionRealm.self, forPrimaryKey: publicKey) {
                    try realm.write {
                        realm.delete(object)
                    }
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onError(RepositoryError.fail)
                }
            } catch {
                SweetLogger.error(error)
                observer.onNext(false)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func saveWallet(_ wallet: Wallet) -> Observable<Wallet> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.add(WalletItem(wallet: wallet), update: .all)
                }
                observer.onNext(wallet)
                observer.onCompleted()
            } catch {
                SweetLogger.error(error)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func saveWallets(_ wallets: [Wallet]) -> Observable<[Wallet]> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            do {
                try realm.write {
                    let walletItems = wallets.map { WalletItem(wallet: $0) }
                    realm.add(walletItems, update: .all)
                }
                observer.onNext(wallets)
                observer.onCompleted()
            } catch {
                SweetLogger.error(error)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func removeWallet(_ wallet: Wallet) -> Observable<Bool> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onNext(false)
                observer.onError(RepositoryError.fail)
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
                    observer.onError(RepositoryError.notFound)
                    SweetLogger.error(RepositoryError.notFound)
                }

                let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address)
                try? realm?.write {
                    realm?.deleteAll()
                }
            } catch {
                SweetLogger.error(error)
                observer.onNext(false)
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            return Disposables.create()
        }
    }

    func wallets(specifications: WalletsRepositorySpecifications) -> Observable<[Wallet]> {
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(WalletItem.self)
                .filter("isLoggedIn == %@", specifications.isLoggedIn)
                .toArray()
                .map { Wallet(wallet: $0) }

            observer.onNext(objects)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func listenerWallet(by publicKey: String) -> Observable<Wallet> {
        // TODO: - .bind(to: observer) странное поведение
        Observable.create { [weak self] observer -> Disposable in

            guard let self = self else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            guard let realm = self.realm else {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }

            let result = realm.objects(WalletItem.self)

            // TODO: - .bind(to: observer) странное поведение
            let collection = Observable.collection(from: result)
            let disposable = collection.flatMap { items -> Observable<Wallet> in
                if let item = items.toArray().first(where: { $0.publicKey == publicKey }) {
                    return Observable.just(Wallet(wallet: item))
                }
                return Observable.empty()
            }
            .bind(to: observer)
            return Disposables.create([disposable])
        }
    }
}

private extension WalletsRepositoryLocal {
    var realm: Realm? {
        guard let config = WalletsRealmFactory.walletsConfig(scheme: "\(environmentRepository.environmentKind.rawValue)") else {
            SweetLogger.error("Realm Configuration is nil")
            return nil
        }

        let realm = try? Realm(configuration: config)
        return realm
    }
}
