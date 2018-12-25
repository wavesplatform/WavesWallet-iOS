//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class DexListRepositoryRemote: DexListRepositoryProtocol {
    
    private let environment = FactoryRepositories.instance.environmentRepository
    private let auth = FactoryInteractors.instance.authorization
    private let apiProvider: MoyaProvider<API.Service.ListPairs> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    
    func list(by pairs: [API.DTO.Pair]) -> Observable<[API.DTO.ListPair]> {

        return auth.authorizedWallet().flatMap({ (wallet) -> Observable<[API.DTO.ListPair]> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ (environment) -> Observable<[API.DTO.ListPair]> in
                    
                    return self.apiProvider.rx
                        .request(.init(pairs: pairs, environment: environment),
                                 callbackQueue: DispatchQueue.global(qos: .userInteractive))
                        .filterSuccessfulStatusAndRedirectCodes()
                        .map(API.Response<[API.OptionalResponse<API.DTO.ListPair>]>.self)
                        .map { $0.data.map {$0.data ?? .empty}}
                        .asObservable()
                })
        })
    }
}
