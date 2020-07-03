//
//  EnvironmentRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import Moya
import RxCocoa
import RxSwift
import WavesSDK
import WavesSDKExtensions


private struct EnvironmentKey: Hashable {
    let chainId: String
}


final class EnvironmentRepository: EnvironmentRepositoryProtocol {
        
    private let environmentRepository: MoyaProvider<ResourceAPI.Service.Environment> = .anyMoyaProvider()
    
    private lazy var remoteAccountEnvironmentShare: Observable<WalletEnvironment> = {
        remoteEnvironment().share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }()
    
    private lazy var currentEnviromentShare: Observable<WalletEnvironment> =
        setupServicesEnviroment().share(replay: 1, scope: SubjectLifetimeScope.whileConnected)

    private var localEnvironments: BehaviorSubject<[EnvironmentKey: WalletEnvironment]> = BehaviorSubject(value: [:])
    
    private lazy var internalEnvironmentKind: WalletEnvironment.Kind = {
          let chainId = UserDefaults.standard.string(forKey: "wallet.environment.kind") ?? ""
          return WalletEnvironment.Kind(rawValue: chainId) ?? .mainnet
    }()
    
    init() {
        setupEnviroment(kind: environmentKind)
    }
            
    func walletEnvironment() -> Observable<WalletEnvironment> {
        currentEnviromentShare
    }
                          
    var environmentKind: WalletEnvironment.Kind {
        get {
            return internalEnvironmentKind
        }
        
        set {
            internalEnvironmentKind = newValue
            //TODO: TSUD
            UserDefaults.standard.set(newValue.rawValue, forKey: "wallet.environment.kind")
            UserDefaults.standard.synchronize()
            
            setupEnviroment(kind: newValue)
        }
    }
}

extension EnvironmentRepository {
    
    private func setupServicesEnviroment() -> Observable<WalletEnvironment> {
        return ifNeedRemoteEnvironment()
            .flatMap { [weak self] enviroment -> Observable<WalletEnvironment> in
                guard let self = self else {
                    return Observable.never()
                }
                
                return self.saveEnvironmentToMemory(environment: enviroment)
        }
    }
        
    private func setupEnviroment(kind: WalletEnvironment.Kind) {
        AddressValidator.walletEnvironment = localEnviromentFromFile(isDebug: ApplicationDebugSettings.isEnableEnviromentTest,
                                                                     kind: kind)
    }
    
    private func localEnviromentFromFile(isDebug: Bool, kind: WalletEnvironment.Kind) -> WalletEnvironment {
        switch environmentKind {
        case .mainnet:
            if isDebug {
                return WalletEnvironment.MainnetTest
            } else {
                return WalletEnvironment.Mainnet
            }
        case .testnet:
            if isDebug {
                return WalletEnvironment.TestnetTest
            } else {
                return WalletEnvironment.Testnet
            }
        case .stagenet:
            if isDebug {
                return WalletEnvironment.StagenetTest
            } else {
                return WalletEnvironment.Stagenet
            }
        }
    }
    
    private func localEnvironment(by key: EnvironmentKey) -> WalletEnvironment? {
        if let value = try? localEnvironments.value() {
            return value[key]
        }
        
        return nil
    }
}

private extension EnvironmentRepository {
        
    private func saveEnvironmentToMemory(environment: WalletEnvironment) -> Observable<WalletEnvironment> {
        Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                return Disposables.create()
            }
            
            let key = EnvironmentKey(chainId: self.environmentKind.rawValue)
            
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
        
        let key = EnvironmentKey(chainId: self.environmentKind.rawValue)
        
        if let enviroment = self.localEnvironment(by: key) {
            return Observable.just(enviroment)
        }
        
        return self.remoteAccountEnvironmentShare
    }
    
    private func remoteEnvironment() -> Observable<WalletEnvironment> {
        environmentRepository
            .rx
            .request(.get(kind: environmentKind,
                          isTest: ApplicationDebugSettings.isEnableEnviromentTest))
            .map(WalletEnvironment.self)
            .catchError { [weak self] _ -> Single<WalletEnvironment> in
                guard let self = self else { return Single.never() }
                
                return Single.just(self.localEnviromentFromFile(isDebug: ApplicationDebugSettings.isEnableEnviromentTest,
                                                                kind: self.environmentKind))
            }
            .asObservable()
    }
}
