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

final class DexPairsPriceRepositoryRemote: DexPairsPriceRepositoryProtocol {
    
    private let environment = FactoryRepositories.instance.environmentRepository
    private let auth = FactoryInteractors.instance.authorization
    private let apiProvider: MoyaProvider<API.Service.PairsPrice> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    
    func list(by pairs: [DomainLayer.DTO.Dex.Pair]) -> Observable<[DomainLayer.DTO.Dex.PairPrice]> {

        return auth.authorizedWallet().flatMap({ (wallet) -> Observable<[DomainLayer.DTO.Dex.PairPrice]> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ (environment) -> Observable<[DomainLayer.DTO.Dex.PairPrice]> in
                    
                    return self.apiProvider.rx
                        .request(.init(pairs: pairs, environment: environment),
                                 callbackQueue: DispatchQueue.global(qos: .userInteractive))
                        .filterSuccessfulStatusAndRedirectCodes()
                        .map(API.Response<[API.OptionalResponse<API.DTO.PairPrice>]>.self)
                        .map { $0.data.map {$0.data ?? .empty}}
                        .map({ (list) -> [DomainLayer.DTO.Dex.PairPrice] in
                            
                            var listPairs: [DomainLayer.DTO.Dex.PairPrice] = []
                            
                            for (index, pair) in list.enumerated() {
                                let localPair = pairs[index]
                                
                                let priceAsset = localPair.priceAsset
                                let firstPrice = Money(value: Decimal(pair.firstPrice), priceAsset.decimals)
                                let lastPrice = Money(value: Decimal(pair.lastPrice), priceAsset.decimals)
                                
                                let pair = DomainLayer.DTO.Dex.PairPrice(firstPrice: firstPrice,
                                                                         lastPrice: lastPrice,
                                                                         amountAsset: localPair.amountAsset,
                                                                         priceAsset: priceAsset)
                                listPairs.append(pair)
                            }
                            
                            return listPairs
                        })
                        .asObservable()
                })
        })
    }
}
