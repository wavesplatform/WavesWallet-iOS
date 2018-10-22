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

final class AccountSettingsRepository: AccountSettingsRepositoryProtocol {

    func accountSettings(accountAddress: String) -> Observable<DomainLayer.DTO.AccountSettings?> {
        return Observable.create({ observer -> Disposable in

            let realm = try! Realm()
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

            let realm = try! Realm()
            try? realm.write {
                realm.deleteAll()
                realm.add(AccountSettings(settings))
            }

            observer.onNext(settings)
            observer.onCompleted()

            return Disposables.create()
        })
    }
}
