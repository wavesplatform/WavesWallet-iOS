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
import WavesSDKExtension

private enum Constants {
    static let minimumOrderFee: Int64 = 300000
    static let numberForConveringDecimals = 8
}

final class DexCreateOrderInteractor: DexCreateOrderInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    private let matcherRepository = FactoryRepositories.instance.matcherRepository
    private let matcherProvider: MoyaProvider<Matcher.Service.OrderBook> = .nodeMoyaProvider()
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository
    private let transactionInteractor = FactoryInteractors.instance.transactions
    private let environmentRepository = FactoryRepositories.instance.environmentRepository
    
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
            
            guard let self = self else { return Observable.empty() }
            
            let matcher = self.matcherRepository.matcherPublicKey(accountAddress: wallet.address)
            let environment = self.environmentRepository.accountEnvironment(accountAddress: wallet.address)

            //TODO: Code move to another method
            return Observable.zip(matcher, environment)
                .flatMap({ [weak self] (matcherPublicKey, environment) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                    guard let self = self else { return Observable.empty() }
                    
                    let precisionDifference =  (order.priceAsset.decimals - order.amountAsset.decimals) + Constants.numberForConveringDecimals
                    
                    let price = (order.price.decimalValue * pow(10, precisionDifference)).int64Value
                    
                    let orderQuery = DomainLayer.Query.Dex.CreateOrder(wallet: wallet,
                                                                       matcherPublicKey: matcherPublicKey,
                                                                       amountAsset: order.amountAsset.id,
                                                                       priceAsset: order.priceAsset.id,
                                                                       amount: order.amount.amount,
                                                                       price: price,
                                                                       orderType: order.type,
                                                                       matcherFee: order.fee,
                                                                       timestamp: Date().millisecondsSince1970(timestampDiff: environment.timestampServerDiff),
                                                                       expiration: Int64(order.expiration.rawValue))
                    
                    
                    return self.orderBookRepository.createOrder(wallet: wallet, order: orderQuery)
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
            guard let self = self else { return Observable.empty() }
            return self.transactionInteractor.calculateFee(by: .createOrder(amountAsset: amountAsset, priceAsset: priceAsset),
                                                            accountAddress: wallet.address)
        })
    }
}
