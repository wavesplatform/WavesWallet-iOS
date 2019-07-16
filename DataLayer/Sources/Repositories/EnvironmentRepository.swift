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
import WavesSDKExtensions
import WavesSDK
import DomainLayer
import Extensions

private enum Constants {
    static let minServerTimestampDiff: Int64 = 1000 * 30
}

private struct EnvironmentKey: Hashable {
    let isTestNet: Bool
}

public final class ApplicationEnviroment: ApplicationEnvironmentProtocol {
    
    public let wavesServices: WavesServicesProtocol
    public private(set) var walletEnvironment: WalletEnvironment
    public private(set) var timestampServerDiff: Int64
    
    init(wavesServices: WavesServicesProtocol, walletEnvironment: WalletEnvironment, timestampServerDiff: Int64) {
        self.wavesServices = wavesServices
        self.timestampServerDiff = timestampServerDiff
        self.walletEnvironment = walletEnvironment
    }
}

protocol ServicesEnvironmentRepositoryProtocol {
    func servicesEnvironment() -> Observable<ApplicationEnviroment>
}

final class EnvironmentRepository: EnvironmentRepositoryProtocol, ServicesEnvironmentRepositoryProtocol {

    private var internalServerTimestampDiff: Int64? = nil
    
    private var serverTimestampDiff: Int64? {
        
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            return internalServerTimestampDiff
        }
        
        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            internalServerTimestampDiff = newValue
        }
    }

    private let environmentRepository: MoyaProvider<GitHub.Service.Environment> = .anyMoyaProvider()
    
    private lazy var remoteAccountEnvironmentShare: Observable<WalletEnvironment> = {
        return remoteEnvironment().share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }()
    
    private lazy var setupServicesEnviromentShare: Observable<ApplicationEnviroment>  = self.setupServicesEnviroment().share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    
    private var localEnvironments: BehaviorSubject<[EnvironmentKey: WalletEnvironment]> = BehaviorSubject<[EnvironmentKey: WalletEnvironment]>(value: [:])
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(timeDidChange), name: UIApplication.significantTimeChangeNotification, object: nil)
    }
    
    func deffaultEnvironment() -> Observable<WalletEnvironment> {
        return remoteAccountEnvironmentShare
    }

    func walletEnvironment() -> Observable<WalletEnvironment> {
        return setupServicesEnviromentShare.map { $0.walletEnvironment }
    }

    func applicationEnvironment() -> Observable<ApplicationEnvironmentProtocol> {
        return setupServicesEnviromentShare.map { $0 as ApplicationEnvironmentProtocol }
    }
    
    func servicesEnvironment() -> Observable<ApplicationEnviroment> {
        return setupServicesEnviromentShare
    }
}

private extension EnvironmentRepository {
    
    private func setupServicesEnviroment() -> Observable<ApplicationEnviroment> {
        
        return self.ifNeedRemoteEnvironment()
            .flatMap { [weak self] (enviroment) -> Observable<WalletEnvironment> in
                
                guard let self = self else {
                    return Observable.never()
                }
                return self.saveEnvironmentToMemory(environment: enviroment)
            }
            .flatMap { [weak self] (enviroment) -> Observable<ApplicationEnviroment> in
                
                guard let self = self else {
                    return Observable.never()
                }
                
                return self.initializationService(environment: enviroment)
                    .map { services in ApplicationEnviroment(wavesServices: services,
                                                             walletEnvironment: enviroment,
                                                             timestampServerDiff: 0) }
            }
            .flatMap { [weak self] (servicesEnviroment) -> Observable<ApplicationEnviroment> in
                
                guard let self = self else {
                    return Observable.never()
                }
                
                if let serverTimestampDiff = self.serverTimestampDiff {
                    return Observable.just(ApplicationEnviroment(wavesServices: servicesEnviroment.wavesServices,
                                                                 walletEnvironment: servicesEnviroment.walletEnvironment,
                                                                 timestampServerDiff: serverTimestampDiff))
                } else {
                    return self.timestampServerDiff(wavesServices: servicesEnviroment.wavesServices)
                        .do(onNext: { [weak self] (serverTimestampDiff) in
                            guard let self = self else {
                                return
                            }
                            self.serverTimestampDiff = serverTimestampDiff
                        })
                        .map { time in
                            return ApplicationEnviroment(wavesServices: servicesEnviroment.wavesServices,
                                                         walletEnvironment: servicesEnviroment.walletEnvironment,
                                                         timestampServerDiff: time)
                    }
                }
            }
            .flatMap({ (enviroment) -> Observable<ApplicationEnviroment> in
                
                var enviromentService = WavesSDK.shared.enviroment
                enviromentService.timestampServerDiff = enviroment.timestampServerDiff
                WavesSDK.shared.enviroment = enviromentService
                
                return Observable.just(enviroment)
            })
        
    }
    
    private func initializationService(environment: WalletEnvironment) -> Observable<WavesServicesProtocol> {
        
        return Observable.create { (observer) -> Disposable in
            
            
            let server: Enviroment.Server = .custom(node: environment.servers.nodeUrl,
                                                    matcher: environment.servers.matcherUrl,
                                                    data: environment.servers.dataUrl,
                                                    scheme: environment.scheme)
            if WavesSDK.isInitialized() {
                
                var enviromentService = WavesSDK.shared.enviroment
                enviromentService.server = server
                    
                WavesSDK.shared.enviroment = enviromentService

                observer.onNext(WavesSDK.shared.services)
                observer.onCompleted()
                return Disposables.create()
            }
                        
            WavesSDK.initialization(servicesPlugins: .init(data: [SentryNetworkLoggerPlugin()],
                                                           node: [NodePlugin(), SentryNetworkLoggerPlugin()],
                                                           matcher: [SentryNetworkLoggerPlugin()]),
                                    enviroment: .init(server: server, timestampServerDiff: 0))
            observer.onNext(WavesSDK.shared.services)
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
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    private func ifNeedRemoteEnvironment() -> Observable<WalletEnvironment> {
        
        return Observable<WalletEnvironment>.create({ [weak self] (observer) -> Disposable in
            
            guard let self = self else {
                return Disposables.create()
            }
            
            let key = EnvironmentKey(isTestNet: WalletEnvironment.isTestNet)
            
            var disposables: [Disposable] = .init()
            
            if let enviroment = self.localEnvironment(by: key) {
                observer.onNext(enviroment)
                observer.onCompleted()
            } else {
                let disposable = self.remoteAccountEnvironmentShare.bind(to: observer)
                disposables.append(disposable)
            }
            
            return Disposables.create(disposables)
        })
    }
    
    private func remoteEnvironment() -> Observable<WalletEnvironment> {

        return environmentRepository
            .rx
            .request(.get(isTestNet: WalletEnvironment.isTestNet, hasProxy: true))
            .catchError({ [weak self] (_) -> PrimitiveSequence<SingleTrait, Response> in
                guard let self = self else { return Single.never() }
                return self
                    .environmentRepository
                    .rx
                    .request(.get(isTestNet: WalletEnvironment.isTestNet, hasProxy: false))
            })
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
}

private extension EnvironmentRepository {
    
    @objc func timeDidChange() {
        serverTimestampDiff = nil
    }
    
    func timestampServerDiff(wavesServices: WavesServicesProtocol) -> Observable<Int64> {

        return wavesServices
            .nodeServices
            .utilsNodeService
            .time()
            .flatMap({ (time) -> Observable<Int64> in
                
                let localTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
                let diff = localTimestamp - time.NTP
                let timestamp = abs(diff) > Constants.minServerTimestampDiff ? diff : 0
                
                return Observable.just(timestamp)
            })
    }
}
