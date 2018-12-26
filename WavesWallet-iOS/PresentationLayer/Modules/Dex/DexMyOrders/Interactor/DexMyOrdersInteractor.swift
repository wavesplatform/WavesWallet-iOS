//
//  DexMyOrdersInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON


fileprivate extension DexMyOrders.DTO.Order {
    
    init(_ model: Matcher.DTO.Order, priceAsset: Dex.DTO.Asset, amountAsset: Dex.DTO.Asset) {
        
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
            type = Dex.DTO.OrderType.sell
        }
        else {
            type = Dex.DTO.OrderType.buy
        }
        
        self.amountAsset = amountAsset
        self.priceAsset = priceAsset
    }
}


final class DexMyOrdersInteractor: DexMyOrdersInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    private let repository = FactoryRepositories.instance.dexOrderBookRepository
    
    var pair: DexTraderContainer.DTO.Pair!
    
    private let sendSubject: PublishSubject<[DexMarket.DTO.Pair]> = PublishSubject<[DexMarket.DTO.Pair]>()

    func myOrders() -> Observable<[DexMyOrders.DTO.Order]> {
        
        return self.repository.myOrders(amountAsset: self.pair.amountAsset.id,
                                        priceAsset: self.pair.priceAsset.id)
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
        
        return auth.authorizedWallet().flatMap({ (wallet) -> Observable<ResponseType<Bool>> in
            
            return Observable.create({ (subscribe) -> Disposable in
                
                let url = GlobalConstants.Matcher.cancelOrder(order.amountAsset.id, order.priceAsset.id)
                
                let cancelRequest = DexMyOrders.DTO.CancelRequest(senderPublicKey: wallet.publicKey, senderPrivateKey: wallet.privateKey, orderId: order.id)
                
                NetworkManager.postRequestWithUrl(url, parameters: cancelRequest.params, complete: { (info, error) in
                    if info != nil {
                        subscribe.onNext(ResponseType(output: true, error: nil))
                    }
                    else {
                        subscribe.onNext(ResponseType(output: nil, error: error))
                    }
                    subscribe.onCompleted()
                })
                
                return Disposables.create()
            })
        })
    }
}
