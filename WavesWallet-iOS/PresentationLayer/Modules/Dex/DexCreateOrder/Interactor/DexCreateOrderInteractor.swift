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

final class DexCreateOrderInteractor: DexCreateOrderInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    private let matcherRepository = FactoryRepositories.instance.matcherRepository
    private let matcherProvider: MoyaProvider<Matcher.Service.OrderBook> = .matcherMoyaProvider()
    private let environment = FactoryRepositories.instance.environmentRepository
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository
    
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
        
        return auth.authorizedWallet().flatMap({ (wallet) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
            
            return self.environment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ (environment) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                  
                    return self.matcherRepository.matcherPublicKey().flatMap({ (matcherPublicKey) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                        
                        let orderQuery = Matcher.Query.CreateOrder(wallet: wallet,
                                                                   matcherPublicKey: matcherPublicKey,
                                                                   amountAsset: order.amountAsset.id,
                                                                   priceAsset: order.priceAsset.id,
                                                                   amount: order.amount.amount,
                                                                   price: order.price.amount,
                                                                   orderType: order.type,
                                                                   matcherFee: order.fee,
                                                                   expiration: order.expiration.rawValue)

                        
                        return self.orderBookRepository.createOrder(order: orderQuery)
                        .flatMap({ (success) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                            let output = DexCreateOrder.DTO.Output(time: Date(milliseconds: orderQuery.timestamp),
                                                                   orderType: order.type,
                                                                   price: order.price,
                                                                   amount: order.amount)
                            return Observable.just(ResponseType(output: output, error: nil))
                        })
                    })
                })
        })
        .catchError({ (error) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
        })
    }
}
