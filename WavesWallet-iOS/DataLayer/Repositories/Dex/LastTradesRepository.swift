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

final class LastTradesRepository: LastTradesRepositoryProtocol {

    private let apiProvider: MoyaProvider<API.Service.Transactions> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let accountEnvironment = FactoryRepositories.instance.environmentRepository
    private let auth = FactoryInteractors.instance.authorization

    func lastTrades(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, limit: Int) -> Observable<[DomainLayer.DTO.DexLastTrade]> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.DexLastTrade]> in
            guard let owner = self else { return Observable.empty() }
            return owner.accountEnvironment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.DexLastTrade]>  in
                    guard let owner = self else { return Observable.empty() }

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso())
                    
                    let filters = API.Query.ExchangeFilters(matcher: nil,
                                                            sender: nil,
                                                            timeStart: nil,
                                                            timeEnd: nil,
                                                            amountAsset: amountAsset.id,
                                                            priceAsset: priceAsset.id,
                                                            after: nil,
                                                            limit: limit)
                    
                    return owner.apiProvider.rx.request(.init(kind: .getExchangeWithFilters(filters), environment: environment),
                                                        callbackQueue: DispatchQueue.global(qos: .userInteractive))
                        .filterSuccessfulStatusAndRedirectCodes()
                        .asObservable()
                        .map(API.Response<[API.Response<API.DTO.ExchangeTransaction>]>.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                        .map { $0.data.map { $0.data } }
                        .flatMap({ (transactions) -> Observable<[DomainLayer.DTO.DexLastTrade]> in
                            
                            var trades: [DomainLayer.DTO.DexLastTrade] = []
                            for tx in transactions {
                                
                                let sum = Money(value: Decimal(tx.price * tx.amount), priceAsset.decimals)
                                let orderType: DomainLayer.DTO.Dex.OrderType = tx.orderType == .sell ? .sell : .buy
                                
                                let model = DomainLayer.DTO.DexLastTrade(time: tx.timestamp,
                                                                         price: Money(value: Decimal(tx.price), priceAsset.decimals),
                                                                         amount: Money(value: Decimal(tx.amount), amountAsset.decimals),
                                                                         sum: sum,
                                                                         type: orderType)
                                trades.append(model)
                            }
                            
                            return Observable.just(trades)
                        })
                })
        })
    }
}
