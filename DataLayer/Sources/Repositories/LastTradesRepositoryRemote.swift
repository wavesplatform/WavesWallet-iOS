//
//  LastTradesRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import Moya
import RxSwift
import WavesSDK

final class LastTradesRepositoryRemote: LastTradesRepositoryProtocol {
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    private let matcherRepository: MatcherRepositoryProtocol

    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols, matcherRepository: MatcherRepositoryProtocol) {
        self.environmentRepository = environmentRepository
        self.matcherRepository = matcherRepository
    }

    func lastTrades(amountAsset: DomainLayer.DTO.Dex.Asset,
                    priceAsset: DomainLayer.DTO.Dex.Asset,
                    limit: Int) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> {
        
        Observable.zip(environmentRepository.servicesEnvironment(),
                       matcherRepository.matcherPublicKey())
            .flatMap { (servicesEnvironment, publicKeyAccount) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in
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
                    .flatMap { transactions -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in

                        var trades: [DomainLayer.DTO.Dex.LastTrade] = []
                        for tx in transactions {
                            let sum = Money(value: Decimal(tx.price * tx.amount), priceAsset.decimals)
                            let orderType: DomainLayer.DTO.Dex.OrderType = tx.orderType == .sell ? .sell : .buy

                            let price = Money(value: Decimal(tx.price), priceAsset.decimals)
                            let amount = Money(value: Decimal(tx.amount), amountAsset.decimals)
                            let model = DomainLayer.DTO.Dex.LastTrade(time: tx.timestamp,
                                                                      price: price,
                                                                      amount: amount,
                                                                      sum: sum,
                                                                      type: orderType)
                            trades.append(model)
                        }

                        return Observable.just(trades)
                    }
            }
    }
}
