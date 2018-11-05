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
    
    init(_ json: JSON, priceDecimals: Int, amountDecimals: Int) {
        
        id = json["id"].stringValue
        price = Money(json["price"].int64Value, priceDecimals)
        amount = Money(json["price"].int64Value, amountDecimals)
        time = Date(milliseconds: json["timestamp"].int64Value)
        
        if json["status"].stringValue == "Accepted" {
            status = DexMyOrders.DTO.Status.accepted
        }
        else if json["status"].stringValue == "PartiallyFilled" {
            status = DexMyOrders.DTO.Status.partiallyFilled
        }
        else if json["status"].stringValue == "Filled" {
            status = DexMyOrders.DTO.Status.filled
        }
        else {
            status = DexMyOrders.DTO.Status.cancelled
        }
        
        filled = Money(json["filled"].int64Value, amountDecimals)
        if json["type"].stringValue == "sell" {
            type = Dex.DTO.OrderType.sell
        }
        else {
            type = Dex.DTO.OrderType.buy
        }
    }
}


final class DexMyOrdersInteractor: DexMyOrdersInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func myOrders() -> Observable<([DexMyOrders.DTO.Order])> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<([DexMyOrders.DTO.Order])> in
            
            guard let owner = self else { return Observable.empty() }
            
            let myOrdersReq = DexMyOrders.DTO.MyOrdersRequest(senderPrivateKey: wallet.privateKey)
            
            let headers: HTTPHeaders = ["timestamp" : String(myOrdersReq.timestamp),
                                        "signature" : Base58.encode(myOrdersReq.signature)]
            
            let url = GlobalConstants.Matcher.myOrderBook(owner.pair.amountAsset.id, owner.pair.priceAsset.id, publicKey: wallet.publicKey)
            
            return Observable.create({ (subscribe) -> Disposable in
                
                NetworkManager.getRequestWithUrl(url, parameters: nil, headers: headers, complete: { (info, error) in

                    var orders: [DexMyOrders.DTO.Order] = []

                    if let info = info {
                        
                        for item in info.arrayValue {
                            orders.append(DexMyOrders.DTO.Order(item,
                                                                priceDecimals: owner.pair.priceAsset.decimals,
                                                                amountDecimals: owner.pair.amountAsset.decimals))
                        }
                    }
                    
                    subscribe.onNext(orders)
                })
                return Disposables.create()
            })
        })
    }
    
 
    func deleteOrder(order: DexMyOrders.DTO.Order) {
        
    }
}
