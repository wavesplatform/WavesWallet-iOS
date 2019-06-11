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
}

//func setSpamURL(_ url: String, by accountAddress: String) -> Observable<Bool> {
//    return Observable.create({ [weak self] (observer) -> Disposable in
//        
//        guard let self = self else {
//            return Disposables.create()
//        }
//        
//        guard url.isValidUrl else {
//            observer.onError(EnvironmentRepositoryError.invalidURL)
//            return Disposables.create()
//        }
//        
//        guard let link = URL(string: url) else {
//            observer.onError(EnvironmentRepositoryError.invalidURL)
//            return Disposables.create()
//        }
//        
//        let disposable = self.spamProvider
//            .rx
//            .request(.getSpamList(url: link))
//            .flatMap({ response -> Single<Bool> in
//                
//                do {
//                    _ = try SpamCVC.addresses(from: response.data)
//                    return Single.just(true)
//                } catch _ {
//                    return Single.error(EnvironmentRepositoryError.invalidResponse)
//                }
//            })
//            .asObservable()
//            .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.AccountEnvironment?> in
//                
//                guard let self = self else {
//                    return Observable.never()
//                }
//                return self.localAccountEnvironment(accountAddress: accountAddress)
//            })
//            .flatMap({ [weak self] account -> Observable<Bool> in
//                
//                guard let self = self else {
//                    return Observable.never()
//                }
//                
//                var newAccount = account ?? DomainLayer.DTO.AccountEnvironment()
//                newAccount.spamUrl = url
//                
//                return self.saveAccountEnvironment(newAccount, accountAddress: accountAddress)
//            })
//            .subscribe(observer)
//        
//        return Disposables.create([disposable])
//    })
//        .sweetDebug("setURL")
//}
//
//private func localAccountEnvironment(accountAddress: String) -> Observable<DomainLayer.DTO.AccountEnvironment?> {
//    return Observable.create { observer -> Disposable in
//        
//        //TODO: Error
//        let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
//        
//        let result = realm.objects(AccountEnvironment.self)
//        
//        guard let environment = result.toArray().first else {
//            observer.onNext(nil)
//            observer.onCompleted()
//            return Disposables.create()
//        }
//        
//        observer.onNext(.init(nodeUrl: environment.nodeUrl,
//                              dataUrl: environment.dataUrl,
//                              spamUrl: environment.spamUrl,
//                              matcherUrl: environment.matcherUrl))
//        observer.onCompleted()
//        
//        return Disposables.create()
//    }
//}
//
//private func saveAccountEnvironment(_ accountEnvironment: DomainLayer.DTO.AccountEnvironment, accountAddress: String) -> Observable<Bool> {
//    return Observable.create { observer -> Disposable in
//        
//        //TODO: Error
//        let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
//        
//        try? realm.write {
//            realm
//                .objects(AccountEnvironment.self)
//                .toArray()
//                .forEach({ account in
//                    account.realm?.delete(account)
//                })
//            let environment = AccountEnvironment()
//            environment.dataUrl = accountEnvironment.dataUrl
//            environment.matcherUrl = accountEnvironment.matcherUrl
//            environment.nodeUrl = accountEnvironment.nodeUrl
//            environment.spamUrl = accountEnvironment.spamUrl
//            realm.add(environment, update: false)
//        }
//        observer.onNext(true)
//        observer.onCompleted()
//        
//        return Disposables.create()
//    }
//}
////
////    let accountEnvironment = self
////        .localAccountEnvironment(accountAddress: accountAddress)
//
////    return Observable
////    .zip(deffaultEnvironment, accountEnvironment)
////    .flatMap(weak: self, selector: { (owner, environments) -> Observable<WalletEnvironment> in
////
////    let environment: WalletEnvironment = owner.merge(environment: environments.0, with: environments.1)
////    return Observable.just(environment)
////    })
//
//private func merge(environment: WalletEnvironment, with accountEnvironment: DomainLayer.DTO.AccountEnvironment?) -> WalletEnvironment {
//    
//    var servers: WalletEnvironment.Servers!
//    
//    if let accountEnvironmet = accountEnvironment {
//        
//        var dataUrl: URL!
//        var matcherUrl: URL!
//        var nodeUrl: URL!
//        var spamUrl: URL!
//        
//        if let data = accountEnvironmet.dataUrl {
//            dataUrl = URL(string: data)
//        }
//        
//        if let matcher = accountEnvironmet.matcherUrl {
//            matcherUrl = URL(string: matcher)
//        }
//        
//        if let node = accountEnvironmet.nodeUrl {
//            nodeUrl = URL(string: node)
//        }
//        
//        if let spam = accountEnvironmet.spamUrl {
//            spamUrl = URL(string: spam)
//        }
//        
//        dataUrl = dataUrl ?? environment.servers.dataUrl
//        matcherUrl = matcherUrl ?? environment.servers.matcherUrl
//        nodeUrl = nodeUrl ?? environment.servers.nodeUrl
//        spamUrl = spamUrl ?? environment.servers.spamUrl
//        
//        servers = .init(nodeUrl: nodeUrl,
//                        dataUrl: dataUrl,
//                        spamUrl: spamUrl,
//                        matcherUrl: matcherUrl)
//    } else {
//        servers = environment.servers
//    }
//    
//    return WalletEnvironment(name: environment.name,
//                             servers: servers,
//                             scheme: environment.scheme,
//                             generalAssets: environment.generalAssets,
//                             assets: environment.assets)
//}
//
