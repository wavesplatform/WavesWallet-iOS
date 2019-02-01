//
//  AliasesRepositoryLocal.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 24/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {
    static var notFoundCode = 404
}
final class AliasesRepositoryLocal: AliasesRepositoryProtocol {

    func aliases(accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {

        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onError(AssetsRepositoryError.fail)
                return Disposables.create()
            }

            let objects = realm.objects(Alias.self)
                .toArray()
                .map { DomainLayer.DTO.Alias(name: $0.name, originalName: $0.originalName) }

            observer.onNext(objects)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    func alias(by name: String, accountAddress: String) -> Observable<String> {
        assertMethodDontSupported()
        return Observable.never()
    }

    func saveAliases(by accountAddress: String, aliases: [DomainLayer.DTO.Alias]) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in

            guard let realm = try? WalletRealmFactory.realm(accountAddress: accountAddress) else {
                observer.onNext(false)
                observer.onError(AliasesRepositoryError.invalid)
                return Disposables.create()
            }

            do {
                try realm.write({
                    realm.add(aliases.map {
                        let alias = Alias()
                        alias.name = $0.name
                        alias.originalName = $0.originalName
                        return alias
                    }, update: true)
                })
                observer.onNext(true)
                observer.onCompleted()
            } catch _ {
                observer.onNext(false)
                observer.onError(AliasesRepositoryError.invalid)
                return Disposables.create()
            }

            return Disposables.create()
        })
    }
}
