//
//  LastTradesRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer
import Extensions

final class LastTradesRepositoryRemote: LastTradesRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocols
    private let matcherRepository: MatcherRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocols, matcherRepository: MatcherRepositoryProtocol) {
        self.environmentRepository = environmentRepository
        self.matcherRepository = matcherRepository
    }
    
    func lastTrades(amountAsset: DomainLayer.DTO.Dex.Asset,
                    priceAsset: DomainLayer.DTO.Dex.Asset,
                    limit: Int) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> {

        return Observable.zip(environmentRepository.servicesEnvironment(), matcherRepository.matcherPublicKey())
            .flatMap({ (servicesEnvironment, publicKeyAccount) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in
                
                let query = DataService.Query.ExchangeFilters(matcher: publicKeyAccount.address,
                                                              sender: nil,
                                                              timeStart: nil,
                                                              timeEnd: nil,
                                                              amountAsset: amountAsset.id,
                                                              priceAsset: priceAsset.id,
                                                              after: nil,
                                                              limit: limit)
                
                return servicesEnvironment
                    .wavesServices
                    .dataServices
                    .transactionsDataService
                    .transactionsExchange(query: query)
                    .flatMap({ (transactions) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in
                        
                        var trades: [DomainLayer.DTO.Dex.LastTrade] = []
                        for tx in transactions {
                            
                            let sum = Money(value: Decimal(tx.price * tx.amount), priceAsset.decimals)
                            let orderType: DomainLayer.DTO.Dex.OrderType = tx.orderType == .sell ? .sell : .buy
                            
                            let model = DomainLayer.DTO.Dex.LastTrade(time: tx.timestamp,
                                                                      price: Money(value: Decimal(tx.price), priceAsset.decimals),
                                                                      amount: Money(value: Decimal(tx.amount), amountAsset.decimals),
                                                                      sum: sum,
                                                                      type: orderType)
                            trades.append(model)
                        }
                        
                        return Observable.just(trades)
                    })
            })
    }
}
