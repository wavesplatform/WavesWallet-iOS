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


private extension String {

    var isValidUrl: Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }
}

private struct EnvironmentKey: Hashable {
    let accountAddress: String
    let isTestNet: Bool
}

final class EnvironmentRepository: EnvironmentRepositoryProtocol {

    private let environmentRepository: MoyaProvider<GitHub.Service.Environment> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    private var localEnvironments: BehaviorSubject<[EnvironmentKey: Environment]> = BehaviorSubject<[EnvironmentKey: Environment]>(value: [:])

    func environment(accountAddress: String) -> Observable<Environment> {

        if let enviroment = localEnvironment(by: .init(accountAddress: "", isTestNet: Environments.isTestNet)) {
            return Observable.just(enviroment)
        } else {
            return remoteEnvironment()
        }
    }

    private func remoteEnvironment() -> Observable<Environment> {
        return Observable.create { [weak self] observer -> Disposable in

            guard let owner = self else {
                return Disposables.create()
            }

            let remote = owner.environmentRepository
                .rx
                .request(.get(isTestNet: Environments.isTestNet))
                .map(Environment.self)
                .catchError { _ -> Single<Environment> in
                    return Single.just(Environments.current)
                }
                .asObservable()

            let accountEnvironment = owner.accountEnvironment()

            let disposable = Observable
                .zip(remote, accountEnvironment)
                .subscribe(weak: owner, onNext: { (owner, environments) in

                    let key = EnvironmentKey(accountAddress: "", isTestNet: false)

                    let environment: Environment = owner.merge(environment: environments.0, with: environments.1)

                    if let value = try? owner.localEnvironments.value() {
                        var newValue = value
                        newValue[key] = environment
                        owner.localEnvironments.onNext(newValue)
                    } else {
                        owner.localEnvironments.onNext([key: environment])
                    }
                    observer.onNext(environment)
                    observer.onCompleted()
                })

            return Disposables.create([disposable])
        }
    }

    func setSpamURL(_ url: String) -> Observable<Bool> {
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
                .flatMap({ [weak self] _ -> Observable<AccountEnvironment?> in

                    guard let owner = self else {
                        return Observable.never()
                    }
                    return owner.accountEnvironment()
                })
                .flatMap({ [weak self] account -> Observable<Bool> in

                    guard let owner = self else {
                        return Observable.never()
                    }

                    let newAccount = account ?? AccountEnvironment()
                    newAccount.spamUrl = url

                    return owner.saveAccountEnvironment(newAccount)
                })
                .subscribe(observer)

            return Disposables.create([disposable])
        })
    }


//    let spamAssets = environment
//        .flatMap { [weak self] environment -> Single<Response> in
//
//            guard let owner = self else { return Single.never() }
//            return owner
//                .spamProvider
//                .rx
//                .request(.init(kind: .getSpamList,
//                               environment: environment),
//                         callbackQueue: DispatchQueue.global(qos: .background))
//        }
//        .map { response -> [String] in
//
//            guard let text = String(data: response.data, encoding: .utf8) else { return [] }
//            guard let csv: CSV = try? CSV(string: text, hasHeaderRow: true) else { return [] }
//
//            var addresses = [String]()
//            while let row = csv.next() {
//                guard let address = scamAddressFrom(row: row) else { continue }
//                addresses.append(address)
//            }
//            return addresses
//        }
//        .asObservable()
//    guard let text = String(data: response.data, encoding: .utf8) else { return [] }
//    guard let csv: CSV = try? CSV(string: text, hasHeaderRow: true) else { return [] }

    private func localEnvironment(by key: EnvironmentKey) -> Environment? {

        if let value = try? localEnvironments.value() {
            return value[key]
        }

        return nil
    }

    private func accountEnvironment() -> Observable<AccountEnvironment?> {
        return Observable.create { observer -> Disposable in
            let realm = try! Realm()

            let result = realm.objects(AccountEnvironment.self)
            observer.onNext(result.toArray().first)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    private func saveAccountEnvironment(_ accountEnvironment: AccountEnvironment) -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            let realm = try! Realm()

            try? realm.write {
                realm.deleteAll()
                realm.add(accountEnvironment, update: false)
            }
            observer.onNext(true)
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func merge(environment: Environment, with accountEnvironmet: AccountEnvironment?) -> Environment {

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
