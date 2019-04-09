//
//  AccountEnvironmentRepository.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxRealm
import RealmSwift
import WavesSDKExtension

final class AccountSettingsRepository: AccountSettingsRepositoryProtocol {

    func accountSettings(accountAddress: String) -> Observable<DomainLayer.DTO.AccountSettings?> {
        return Observable.create({ observer -> Disposable in

            //TODO: Error
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            let result = realm.objects(AccountSettings.self)

            if let settings = result.toArray().first {
                observer.onNext(DomainLayer.DTO.AccountSettings(settings))
                observer.onCompleted()
            } else {
                observer.onNext(nil)
                observer.onCompleted()
            }

            return Disposables.create()
        })
    }

    func saveAccountSettings(accountAddress: String, settings: DomainLayer.DTO.AccountSettings) -> Observable<DomainLayer.DTO.AccountSettings> {
        return Observable.create({ observer -> Disposable in

            do {
                let realm = try WalletRealmFactory.realm(accountAddress: accountAddress)
                try realm.write {

                    let result = realm.objects(AccountSettings.self)
                    realm.delete(result)
                    
                    realm.add(AccountSettings(settings))
                }
                
            } catch let e {
                SweetLogger.debug(e)
                observer.onError(AccountSettingsRepositoryError.invalid)
            }

            observer.onNext(settings)
            observer.onCompleted()

            return Disposables.create()
        })
    }
}
