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

// На данный момент это точная копия из клиента
// Нужно вынести зависимость из DataLayer
enum ResourceAPI {}

extension ResourceAPI {
    enum Service {}
    enum DTO {}
}

private enum Constants {
    static let root = "https://configs.waves.exchange/"
}

private extension URL {
    static func configURL(isTest: Bool,
                          enviromentScheme: String,
                          configName: String) -> URL {
        var path = "\(Constants.root)"
        path += "mobile/v2/"
        path += "\(configName)/"
        if isTest {
            path += "test/"
        } else {
            path += "prod/"
        }
        
        path += "\(enviromentScheme).json"
                        
        return URL(string: path)!
    }
}

extension WalletEnvironment.Kind {
    
    var enviromentScheme: String {
        switch self {
        case .mainnet:
            return "mainnet"
        case .wxdevnet:
            return "wxdevnet"
        case .testnet:
            return "testnet"
        }
    }
}

extension ResourceAPI.Service {

    enum Environment {

        /**
         Response:
         - Environment
         */
        case get(kind: WalletEnvironment.Kind, isTest: Bool)
    }

}

extension ResourceAPI.Service.Environment: TargetType {
    var sampleData: Data {
        return Data()
    }

    var baseURL: URL {
        switch self {
        case let .get(kind, isTest):
            
            return URL.configURL(isTest: isTest,
                                 enviromentScheme: kind.enviromentScheme,
                                 configName: "environment")
        }
    }

    var path: String {
        return ""
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .get:
            return .requestPlain
        }
    }
}

// MARK: CachePolicyTarget

extension ResourceAPI.Service.Environment: CachePolicyTarget {
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }
}

private struct EnvironmentKey: Hashable {
    let chainId: String
}

public final class WidgetEnvironmentRepository: EnvironmentRepositoryProtocol {
        
    private let environmentRepository: MoyaProvider<ResourceAPI.Service.Environment> = .init()
    
    private lazy var currentEnviromentShare: Observable<WalletEnvironment> =
        setupServicesEnviroment().share(replay: 1, scope: SubjectLifetimeScope.whileConnected)

    private var localEnvironments: BehaviorSubject<[EnvironmentKey: WalletEnvironment]> = BehaviorSubject(value: [:])
    
    private lazy var internalEnvironmentKind: WalletEnvironment.Kind = {
          let chainId = UserDefaults.standard.string(forKey: "wallet.environment.kind") ?? ""
          return WalletEnvironment.Kind(rawValue: chainId) ?? .mainnet
    }()
    
    public init() {}
            
    public func walletEnvironment() -> Observable<WalletEnvironment> {
        currentEnviromentShare
    }
                          
    public var environmentKind: WalletEnvironment.Kind {
        get {
            return internalEnvironmentKind
        }
        
        set {
            internalEnvironmentKind = newValue
            //TODO: TSUD
            UserDefaults.standard.set(newValue.rawValue, forKey: "wallet.environment.kind")
            UserDefaults.standard.synchronize()
            currentEnviromentShare = setupServicesEnviroment().share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        }
    }
}

extension WidgetEnvironmentRepository {
    
    private func setupServicesEnviroment() -> Observable<WalletEnvironment> {
        return ifNeedRemoteEnvironment()
            .flatMap { [weak self] environment -> Observable<WalletEnvironment> in
                guard let self = self else {
                    return Observable.never()
                }
                                                
                return self.saveEnvironmentToMemory(environment: environment)
        }
    }
        
    private func localEnvironment(by key: EnvironmentKey) -> WalletEnvironment? {
        if let value = try? localEnvironments.value() {
            return value[key]
        }
        
        return nil
    }
}

private extension WidgetEnvironmentRepository {
        
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
        
        return remoteEnvironment()
    }
    
    private func remoteEnvironment() -> Observable<WalletEnvironment> {
        environmentRepository
            .rx
            .request(.get(kind: environmentKind,
                          isTest: ApplicationDebugSettings.isEnableEnviromentTest))
            .map(WalletEnvironment.self)
            .asObservable()
    }
}
