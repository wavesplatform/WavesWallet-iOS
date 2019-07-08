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

final class LastTradesRepositoryRemote: LastTradesRepositoryProtocol {

    private let apiProvider: MoyaProvider<API.Service.Transactions> = .nodeMoyaProvider()
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func lastTrades(accountAddress: String, amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, limit: Int) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> {

        return environmentRepository.accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.LastTrade]>  in
                guard let self = self else { return Observable.empty() }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    return Date(isoDecoder: decoder, timestampDiff: environment.timestampServerDiff)
                }
                let filters = API.Query.ExchangeFilters(matcher: nil,
                                                        sender: nil,
                                                        timeStart: nil,
                                                        timeEnd: nil,
                                                        amountAsset: amountAsset.id,
                                                        priceAsset: priceAsset.id,
                                                        after: nil,
                                                        limit: limit)
                
                return self
                    .apiProvider
                    .rx
                    .request(.init(kind: .getExchangeWithFilters(filters),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .asObservable()
                    .map(API.Response<[API.Response<API.DTO.ExchangeTransaction>]>.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                    .map { $0.data.map { $0.data } }
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
