//
//  EnvironmentRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxRealm
import RxSwift

private struct EnvironmentKey: Hashable {
    let accountAddress: String
    let isTestNet: Bool
}

final class EnvironmentRepository: EnvironmentRepositoryProtocol {

    private let environmentRepository: MoyaProvider<GitHub.Service.Environment> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    private var localEnvironments: BehaviorSubject<[EnvironmentKey: Environment]> = BehaviorSubject<[EnvironmentKey: Environment]>(value: [:])

    func deffaultEnvironment(accountAddress: String) -> Observable<Environment> {

        var observer: Observable<Environment>! = nil

        if let enviroment = localEnvironment(by: .init(accountAddress: accountAddress, isTestNet: Environments.isTestNet)) {
            observer = Observable.just(enviroment)
        } else {
            observer = remoteEnvironment(accountAddress: accountAddress)
        }

        return observer
    }

    func accountEnvironment(accountAddress: String) -> Observable<Environment> {

        let deffaultEnvironment: Observable<Environment> = self.deffaultEnvironment(accountAddress: accountAddress)
        let accountEnvironment = self.localAccountEnvironment(accountAddress: accountAddress)

        return Observable
            .zip(deffaultEnvironment, accountEnvironment)
            .flatMap(weak: self, selector: { (owner, environments) -> Observable<Environment> in

                let environment: Environment = owner.merge(environment: environments.0, with: environments.1)
                return Observable.just(environment)
            })
            .do(onNext: { [weak self] environment in

                guard let owner = self else {
                    return
                }

                let key = EnvironmentKey(accountAddress: accountAddress, isTestNet: Environments.isTestNet)

                if let value = try? owner.localEnvironments.value() {
                    var newValue = value
                    newValue[key] = environment
                    owner.localEnvironments.onNext(newValue)
                } else {
                    owner.localEnvironments.onNext([key: environment])
                }
            })
            .sweetDebug("accountEnvironment")
    }

    private func remoteEnvironment(accountAddress: String) -> Observable<Environment> {

        return environmentRepository
            .rx
            .request(.get(isTestNet: Environments.isTestNet))
            .map(Environment.self)
            .catchError { _ -> Single<Environment> in
                return Single.just(Environments.current)
            }
            .asObservable()
    }

    func setSpamURL(_ url: String, by accountAddress: String) -> Observable<Bool> {
        return Observable.create({ [weak self] (observer) -> Disposable in

            guard let owner = self else {
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

            let disposable = owner.spamProvider
                .rx
                .request(.getSpamList(url: link))
                .flatMap({ response -> Single<Bool> in

                    do {
                        _ = try SpamCVC.addresses(from: response.data)
                        return Single.just(true)
                    } catch _ {
                        return Single.error(EnvironmentRepositoryError.invalidResponse)
                    }
                })
                .asObservable()
                .flatMap({ [weak self] _ -> Observable<DomainLayer.DTO.AccountEnvironment?> in

                    guard let owner = self else {
                        return Observable.never()
                    }
                    return owner.localAccountEnvironment(accountAddress: accountAddress)
                })
                .flatMap({ [weak self] account -> Observable<Bool> in

                    guard let owner = self else {
                        return Observable.never()
                    }

                    var newAccount = account ?? DomainLayer.DTO.AccountEnvironment()
                    newAccount.spamUrl = url

                    return owner.saveAccountEnvironment(newAccount, accountAddress: accountAddress)
                })
                .subscribe(observer)

            return Disposables.create([disposable])
        })
        .sweetDebug("setURL")
    }

    private func localEnvironment(by key: EnvironmentKey) -> Environment? {

        if let value = try? localEnvironments.value() {
            return value[key]
        }

        return nil
    }

    private func localAccountEnvironment(accountAddress: String) -> Observable<DomainLayer.DTO.AccountEnvironment?> {
        return Observable.create { observer -> Disposable in
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

    private func saveAccountEnvironment(_ accountEnvironment: DomainLayer.DTO.AccountEnvironment, accountAddress: String) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
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

    func merge(environment: Environment, with accountEnvironmet: DomainLayer.DTO.AccountEnvironment?) -> Environment {

        var servers: Environment.Servers!

        if let accountEnvironmet = accountEnvironmet {

            var dataUrl: URL!
            var matcherUrl: URL!
            var nodeUrl: URL!
            var spamUrl: URL!

            if let data = accountEnvironmet.dataUrl {
                dataUrl = URL(string: data)
            }

            if let matcher = accountEnvironmet.matcherUrl {
                matcherUrl = URL(string: matcher)
            }

            if let node = accountEnvironmet.nodeUrl {
                nodeUrl = URL(string: node)
            }

            if let spam = accountEnvironmet.spamUrl {
                spamUrl = URL(string: spam)
            }

            dataUrl = dataUrl ?? environment.servers.dataUrl
            matcherUrl = matcherUrl ?? environment.servers.matcherUrl
            nodeUrl = nodeUrl ?? environment.servers.nodeUrl
            spamUrl = spamUrl ?? environment.servers.spamUrl

            servers = .init(nodeUrl: nodeUrl,
                            dataUrl: dataUrl,
                            spamUrl: spamUrl,
                            matcherUrl: matcherUrl)
        } else {
            servers = environment.servers
        }

        return Environment(name: environment.name,
                           servers: servers,
                           scheme: environment.scheme,
                           generalAssetIds: environment.generalAssetIds)
    }
}
