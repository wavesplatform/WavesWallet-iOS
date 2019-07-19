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
import WavesSDKExtensions
import DomainLayer
import Extensions
import Moya

final class AccountSettingsRepository: AccountSettingsRepositoryProtocol {
    
    private let spamAssetsService: SpamAssetsService = SpamAssetsService()
    
    func accountSettings(accountAddress: String) -> Observable<DomainLayer.DTO.AccountSettings?> {
        return Observable.create({ observer -> Disposable in

            do {
                let realm = try WalletRealmFactory.realm(accountAddress: accountAddress)
                let result = realm.objects(AccountSettings.self)
                
                if let settings = result.toArray().first {
                    observer.onNext(DomainLayer.DTO.AccountSettings(settings))
                    observer.onCompleted()
                } else {
                    observer.onNext(nil)
                    observer.onCompleted()
                }
                
                return Disposables.create()
            } catch let e {
                SweetLogger.debug(e)
                observer.onError(AccountSettingsRepositoryError.invalid)
                return Disposables.create()
            }
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
                
                observer.onNext(settings)
                observer.onCompleted()
                
                return Disposables.create()
                
            } catch let e {
                SweetLogger.debug(e)
                observer.onError(AccountSettingsRepositoryError.invalid)
                return Disposables.create()
            }

        })
    }
    
    func setSpamURL(_ url: String, by accountAddress: String) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in
    
            guard let self = self else {
                return Disposables.create()
            }
    
            guard url.isValidUrl else {
                observer.onError(EnvironmentRepositoryError.invalidURL)
                return Disposables.create()
            }
    
            guard let link = URL(string: url) else {
                observer.onError(EnvironmentRepositoryError.invalidURL)
                return Disposables.create()
            }
            
            let disposable = self
                .spamAssetsService
                .spamAssets(by: link)
                .catchError({ _ -> Observable<[SpamAssetId]> in
                    return Observable.error(EnvironmentRepositoryError.invalidResponse)
                })
                .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.AccountEnvironment?> in
    
                    guard let self = self else {
                        return Observable.never()
                    }
                    return self.accountEnvironment(accountAddress: accountAddress)
                })
                .flatMap({ [weak self] account -> Observable<Bool> in
    
                    guard let self = self else {
                        return Observable.never()
                    }
                    
                    let newAccount = account ?? DomainLayer.DTO.AccountEnvironment(nodeUrl: "",
                                                                                   dataUrl: "",
                                                                                   spamUrl: url,
                                                                                   matcherUrl: "")
    
                    return self.saveAccountEnvironment(newAccount, accountAddress: accountAddress)
                })
                .subscribe(observer)
    
            return Disposables.create([disposable])
        })
    }
    
    func accountEnvironment(accountAddress: String) -> Observable<DomainLayer.DTO.AccountEnvironment?> {
        
        return Observable.create { observer -> Disposable in
            
            //TODO: Error
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            let result = realm.objects(AccountEnvironment.self)
            
            guard let environment = result.toArray().first else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            observer.onNext(.init(nodeUrl: environment.nodeUrl,
                                  dataUrl: environment.dataUrl,
                                  spamUrl: environment.spamUrl,
                                  matcherUrl: environment.matcherUrl))
            observer.onCompleted()
            
            return Disposables.create()
        }
    }

    func saveAccountEnvironment(_ accountEnvironment: DomainLayer.DTO.AccountEnvironment,
                                accountAddress: String) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            
            //TODO: Error
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            try? realm.write {
                realm
                    .objects(AccountEnvironment.self)
                    .toArray()
                    .forEach({ account in
                        account.realm?.delete(account)
                    })
                
                let environment = AccountEnvironment()
                environment.dataUrl = accountEnvironment.dataUrl
                environment.matcherUrl = accountEnvironment.matcherUrl
                environment.nodeUrl = accountEnvironment.nodeUrl
                environment.spamUrl = accountEnvironment.spamUrl
                realm.add(environment, update: false)
            }
            observer.onNext(true)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
