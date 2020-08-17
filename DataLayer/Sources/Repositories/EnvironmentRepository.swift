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

public final class EnvironmentRepository: EnvironmentRepositoryProtocol {
    private let environmentRepository: MoyaProvider<ResourceAPI.Service.Environment> = .anyMoyaProvider()

    private lazy var remoteEnvironmentShare: Observable<WalletEnvironment> =
        remoteEnvironment().share(replay: 1, scope: SubjectLifetimeScope.forever)

    private lazy var currentEnviromentShare: Observable<WalletEnvironment> =
        setupServicesEnviroment().share(replay: 1, scope: SubjectLifetimeScope.forever)

    private var localEnvironments: BehaviorSubject<[UInt8: WalletEnvironment]> = BehaviorSubject(value: [:])

    private lazy var internalEnvironmentKind: WalletEnvironment.Kind = {
        let chainId = UserDefaults.standard.string(forKey: "wallet.environment.kind") ?? ""
        return WalletEnvironment.Kind(rawValue: chainId) ?? .mainnet
    }()

    public func walletEnvironment() -> Observable<WalletEnvironment> {
        currentEnviromentShare
    }

    public var environmentKind: WalletEnvironment.Kind {
        get {
            return internalEnvironmentKind
        }

        set {
            internalEnvironmentKind = newValue
            // TODO: TSUD
            UserDefaults.standard.set(newValue.rawValue, forKey: "wallet.environment.kind")
            UserDefaults.standard.synchronize()
            remoteEnvironmentShare = remoteEnvironment().share(replay: 1, scope: SubjectLifetimeScope.forever)
            currentEnviromentShare = setupServicesEnviroment().share(replay: 1, scope: SubjectLifetimeScope.forever)
        }
    }
}

extension EnvironmentRepository {
    private func setupServicesEnviroment() -> Observable<WalletEnvironment> {
        return ifNeedRemoteEnvironment()
            .flatMapLatest { [weak self] environment -> Observable<WalletEnvironment> in
                guard let self = self else {
                    return Observable.never()
                }

                return self.saveEnvironmentToMemory(environment: environment)
            }
    }

    private func localEnvironment(by key: UInt8) -> WalletEnvironment? {
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

            let key = self.environmentKind.chainId

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
        let key = environmentKind.chainId

        if let enviroment = localEnvironment(by: key) {
            return Observable.just(enviroment)
        }

        return remoteEnvironmentShare
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
