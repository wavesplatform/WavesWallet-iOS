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
import WavesSDKExtension
import WavesSDK

private enum Constants {
    static let minServerTimestampDiff: Int64 = 1000 * 30
}

private struct EnvironmentKey: Hashable {
    let isTestNet: Bool
}

public final class ServicesEnviroment {
    
    public let wavesServices: WavesServicesProtocol
    public let walletEnvironment: WalletEnvironment
    
    init(wavesServices: WavesServicesProtocol, walletEnvironment: WalletEnvironment) {
        self.wavesServices = wavesServices
        self.walletEnvironment = walletEnvironment
    }
}

protocol ServicesEnvironmentRepositoryProtocol {
    func servicesEnvironment() -> Observable<ServicesEnviroment>
}

final class EnvironmentRepository: EnvironmentRepositoryProtocol, ServicesEnvironmentRepositoryProtocol {

    private var isValidServerTimestampDiff = false
    private let environmentRepository: MoyaProvider<GitHub.Service.Environment> = .anyMoyaProvider()
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .anyMoyaProvider()
    
    private lazy var remoteAccountEnvironmentShare: Observable<WalletEnvironment> = {
        return remoteEnvironment().share()
    }()
    
    //TODO: Library
    private lazy var accountEnvironmentShare: Observable<WalletEnvironment> = {
        return Observable<Int>.timer(5, scheduler: MainScheduler.asyncInstance)
            .flatMap({ (_) -> Observable<WalletEnvironment> in
                return self.setupEnvironment().share()
            }).share()
    }()
    
    private var localEnvironments: BehaviorSubject<[EnvironmentKey: WalletEnvironment]> = BehaviorSubject<[EnvironmentKey: WalletEnvironment]>(value: [:])
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(timeDidChange), name: UIApplication.significantTimeChangeNotification, object: nil)
    }
    
    func deffaultEnvironment(accountAddress: String) -> Observable<WalletEnvironment> {
        return remoteAccountEnvironmentShare
    }

    func accountEnvironment(accountAddress: String) -> Observable<WalletEnvironment> {
        return accountEnvironmentShare
    }
    
    private func setupEnvironment() -> Observable<WalletEnvironment> {
        
        return self.ifNeedRemoteEnvironment()
        .flatMap { [weak self] (enviroment) -> Observable<WalletEnvironment> in
            
            guard let self = self else {
                return Observable.never()
            }
            
            return self.initializationService(environment: enviroment).map { _ in enviroment }
        }
        .flatMap { [weak self] (enviroment) -> Observable<WalletEnvironment> in
            
            guard let self = self else {
                return Observable.never()
            }

            return self.updateTimestampServerDiff(environment: enviroment)
        }
        .flatMap { [weak self] (enviroment) -> Observable<WalletEnvironment> in
            
            guard let self = self else {
                return Observable.never()
            }
            return self.saveEnvironmentToMemory(environment: enviroment)
        }
    }
    
    private func initializationService(environment: WalletEnvironment) -> Observable<Void> {
        
        return Observable.create { (observer) -> Disposable in
            
            
            let server: Enviroment.Server = .custom(node: environment.servers.nodeUrl,
                                                             matcher: environment.servers.matcherUrl,
                                                             data: environment.servers.dataUrl,
                                                             scheme: environment.scheme)
            if WavesSDK.isInitialized() {
                
                var enviromentService = WavesSDK.shared.enviroment
                enviromentService.server = server
                enviromentService.timestampServerDiff = environment.timestampServerDiff
                    
                WavesSDK.shared.enviroment = enviromentService
                
                observer.onCompleted()
                return Disposables.create()
            }
            
            WavesSDK.initialization(servicesPlugins: .init(data: [], node: [], matcher: []),
                                    enviroment: .init(server: server, timestampServerDiff: 0))
            observer.onNext(())
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    private func saveEnvironmentToMemory(environment: WalletEnvironment) -> Observable<WalletEnvironment> {
        return Observable.create { [weak self] (observer) -> Disposable in
            
            guard let self = self else {
                return Disposables.create()
            }
            
            let key = EnvironmentKey(isTestNet: WalletEnvironment.isTestNet)
            
            //TODO: mutex
            if let value = try? self.localEnvironments.value() {
                var newValue = value
                newValue[key] = environment
                self.localEnvironments.onNext(newValue)
            } else {
                self.localEnvironments.onNext([key: environment])
            }
            
            observer.onNext(environment)
//            observer.onCompleted()
            
            return Disposables.create()
        }
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

            let disposable = self.spamProvider
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

                    guard let self = self else {
                        return Observable.never()
                    }
                    return self.localAccountEnvironment(accountAddress: accountAddress)
                })
                .flatMap({ [weak self] account -> Observable<Bool> in

                    guard let self = self else {
                        return Observable.never()
                    }

                    var newAccount = account ?? DomainLayer.DTO.AccountEnvironment()
                    newAccount.spamUrl = url

                    return self.saveAccountEnvironment(newAccount, accountAddress: accountAddress)
                })
                .subscribe(observer)

            return Disposables.create([disposable])
        })
        .sweetDebug("setURL")
    }
    
    // Loading
    func servicesEnvironment() -> Observable<ServicesEnviroment> {
        
        return self
            .accountEnvironmentShare
            .map { (walletEnvironment) -> ServicesEnviroment in
                
                return ServicesEnviroment(wavesServices: WavesSDK.shared.services,
                                          walletEnvironment: walletEnvironment)
            }
        
        return Observable.never()
    }

}

private extension EnvironmentRepository {
    
    private func ifNeedRemoteEnvironment() -> Observable<WalletEnvironment> {
        
        return Observable<WalletEnvironment>.create({ [weak self] (observer) -> Disposable in
            
            guard let self = self else {
                return Disposables.create()
            }
            
            let key = EnvironmentKey(isTestNet: WalletEnvironment.isTestNet)
            
            var deffaultEnvironment: Observable<WalletEnvironment>!
            
            if let enviroment = self.localEnvironment(by: key) {
                deffaultEnvironment = Observable.just(enviroment)
                print("local")
            } else {
                deffaultEnvironment = self.remoteAccountEnvironmentShare
                print("Remote")
            }
            
            
            let disposable = deffaultEnvironment.bind(to: observer)
            
            return Disposables.create([disposable])
        })
        
    }
    
    
    private func remoteEnvironment() -> Observable<WalletEnvironment> {
        
        //TODO: function call 6 times, after user input passcode
        return environmentRepository
            .rx
            .request(.get(isTestNet: WalletEnvironment.isTestNet))
            .map(WalletEnvironment.self)
            .catchError { error -> Single<WalletEnvironment> in
                return Single.just(WalletEnvironment.current)
            }
            .asObservable()
    }
    
    private func localEnvironment(by key: EnvironmentKey) -> WalletEnvironment? {
        
        if let value = try? localEnvironments.value() {
            return value[key]
        }
        
        return nil
    }
    
    private func localAccountEnvironment(accountAddress: String) -> Observable<DomainLayer.DTO.AccountEnvironment?> {
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
    
    private func saveAccountEnvironment(_ accountEnvironment: DomainLayer.DTO.AccountEnvironment, accountAddress: String) -> Observable<Bool> {
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
//
//    let accountEnvironment = self
//        .localAccountEnvironment(accountAddress: accountAddress)
    
//    return Observable
//    .zip(deffaultEnvironment, accountEnvironment)
//    .flatMap(weak: self, selector: { (owner, environments) -> Observable<WalletEnvironment> in
//
//    let environment: WalletEnvironment = owner.merge(environment: environments.0, with: environments.1)
//    return Observable.just(environment)
//    })
    
    private func merge(environment: WalletEnvironment, with accountEnvironment: DomainLayer.DTO.AccountEnvironment?) -> WalletEnvironment {
        
        var servers: WalletEnvironment.Servers!
        
        if let accountEnvironmet = accountEnvironment {
            
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
        
        return WalletEnvironment(name: environment.name,
                                 servers: servers,
                                 scheme: environment.scheme,
                                 generalAssets: environment.generalAssets,
                                 assets: environment.assets)
    }
    
}

private extension EnvironmentRepository {
    
    @objc func timeDidChange() {
        isValidServerTimestampDiff = false
    }
    
    func updateTimestampServerDiff(environment: WalletEnvironment) -> Observable<WalletEnvironment> {

        if self.isValidServerTimestampDiff == true {
            return Observable.just(environment)
        }
        
        return WavesSDK
            .shared
            .services
            .nodeServices
            .utilsNodeService
            .time()
            .flatMap({ [weak self] (time) -> Observable<WalletEnvironment> in
                
                guard let self = self else { return Observable.empty() }
                self.isValidServerTimestampDiff = true
                
                let localTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
                let diff = localTimestamp - time.NTP
                let timestamp = abs(diff) > Constants.minServerTimestampDiff ? diff : 0
                
                WalletEnvironment.updateTimestampServerDiff(timestamp)
                
                var enviromentService = WavesSDK.shared.enviroment
                enviromentService.timestampServerDiff = environment.timestampServerDiff
                
                WavesSDK.shared.enviroment = enviromentService

                return Observable.just(environment)
            })
    }
}
