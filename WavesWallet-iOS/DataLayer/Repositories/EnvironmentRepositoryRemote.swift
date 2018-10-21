//
//  EnvironmentRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import RxSwift


final class EnvironmentRepositoryLocal: EnvironmentRepositoryProtocol {

    private let environmentRepository: MoyaProvider<GitHub.Service.Environment> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])


    private var lastEnvironment: Environment? = nil

    func environment() -> Observable<Environment> {

        if let lastEnvironment = lastEnvironment {
            return environmentRepository
                .rx
                .request(.get)
                .map(Environment.self)
                .flatMap({ environment -> PrimitiveSequence<SingleTrait, R> in

                })
        } else {

        }



        return Observable.just(Environments.Mainnet)
    }

    func setSpamURL(_ url: URL) -> Observable<Bool> {
        return Observable.never()
    }

    private func getEnvironment() -> Single<Environment> {

        return environmentRepository
            .rx
            .request(.get)
            .map(Environment.self)
    }
}

final class EnvironmentRepositoryRemote: EnvironmentRepositoryProtocol {
    func environment() -> Observable<Environment> {
        return Observable.just(Environments.Mainnet)
    }
}
