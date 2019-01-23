//
//  DexCreateOrderInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

private enum Constants {
    static let minimumOrderFee: Int64 = 300000
}

final class DexCreateOrderInteractor: DexCreateOrderInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    private let matcherRepository = FactoryRepositories.instance.matcherRepository
    private let matcherProvider: MoyaProvider<Matcher.Service.OrderBook> = .nodeMoyaProvider()
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository
    private let transactionInteractor = FactoryInteractors.instance.transactions
    
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
            
            guard let owner = self else { return Observable.empty() }
            
            return owner.matcherRepository.matcherPublicKey(accountAddress: wallet.address)
                .flatMap({ [weak self] (matcherPublicKey) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                    guard let owner = self else { return Observable.empty() }
                    
                    let orderQuery = DomainLayer.Query.Dex.CreateOrder(wallet: wallet,
                                                                       matcherPublicKey: matcherPublicKey,
                                                                       amountAsset: order.amountAsset.id,
                                                                       priceAsset: order.priceAsset.id,
                                                                       amount: order.amount.amount,
                                                                       price: order.price.amount,
                                                                       orderType: order.type,
                                                                       matcherFee: order.fee,
                                                                       expiration: order.expiration.rawValue)

                    
                    return owner.orderBookRepository.createOrder(wallet: wallet, order: orderQuery)
                    .flatMap({ (success) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                        let output = DexCreateOrder.DTO.Output(time: Date(milliseconds: orderQuery.timestamp),
                                                               orderType: order.type,
                                                               price: order.price,
                                                               amount: order.amount)
                        return Observable.just(ResponseType(output: output, error: nil))
                    })
            })
        })
        .catchError({ (error) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
        })
    }
    
    func getFee(amountAsset: String, priceAsset: String) -> Observable<Money> {
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) ->  Observable<Money> in
            guard let owner = self else { return Observable.empty() }
            return owner.transactionInteractor.calculateFee(by: .createOrder(amountAsset: amountAsset, priceAsset: priceAsset),
                                                            accountAddress: wallet.address)
        })
        .catchError({ (error) -> Observable<Money> in
            return Observable.just(Money(Constants.minimumOrderFee, GlobalConstants.WavesDecimals))
        })
    }
}
