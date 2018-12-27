//
//  DexMyOrdersInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

fileprivate extension DexMyOrders.DTO.Order {
    
    init(_ model: Matcher.DTO.Order, priceAsset: DomainLayer.DTO.Dex.Asset, amountAsset: DomainLayer.DTO.Dex.Asset) {
        
        id = model.id
        
        price = DexList.DTO.price(amount: model.price, amountDecimals: amountAsset.decimals, priceDecimals: priceAsset.decimals)
        
        amount = Money(model.amount, amountAsset.decimals)
        time = model.timestamp
        filled = Money(model.filled, amountAsset.decimals)

        if model.status == .Accepted {
            status = .accepted
        }
        else if model.status == .PartiallyFilled {
            status = .partiallyFilled
        }
        else if model.status == .Filled {
            status = .filled
        }
        else {
            status = .cancelled
        }
        
        if model.type == .sell {
            type = .sell
        }
        else {
            type = .buy
        }
        
        self.amountAsset = amountAsset
        self.priceAsset = priceAsset
    }
}


final class DexMyOrdersInteractor: DexMyOrdersInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    private let repository = FactoryRepositories.instance.dexOrderBookRepository
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func myOrders() -> Observable<[DexMyOrders.DTO.Order]> {
        
        return repository.myOrders(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id)
            .flatMap({ [weak self] (orders) -> Observable<[DexMyOrders.DTO.Order]> in
                
                guard let owner = self else { return Observable.empty() }
                
                var myOrders: [DexMyOrders.DTO.Order] = []
                
                for order in orders {
                    myOrders.append(DexMyOrders.DTO.Order(order,
                                                          priceAsset: owner.pair.priceAsset,
                                                          amountAsset: owner.pair.amountAsset))
                    
                }
                return Observable.just(myOrders)
            })
            .catchError({ (error) -> Observable<[DexMyOrders.DTO.Order]> in
                return Observable.just([])
            })
    }
    
 
    func cancelOrder(order: DexMyOrders.DTO.Order) -> Observable<ResponseType<Bool>> {
        
        return repository.cancelOrder(orderId: order.id, amountAsset: order.amountAsset.id, priceAsset: order.priceAsset.id)
            .flatMap({ (status) -> Observable<ResponseType<Bool>> in
                return Observable.just(ResponseType(output: true, error: nil))
            })
            .catchError({ (error) -> Observable<ResponseType<Bool>> in
                return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
            })
    }
}
