//
//  DexCreateOrderInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexCreateOrderInteractor: DexCreateOrderInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    private let matcherRepository = FactoryRepositories.instance.matcherRepository
    
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
       
        return Observable.zip(auth.authorizedWallet(), matcherRepository.matcherPublicKey())
            .flatMap({ (wallet, matcherKey) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in

                var newOrder = order
                newOrder.senderPrivateKey = wallet.privateKey
                newOrder.senderPublicKey = wallet.publicKey
                newOrder.matcherPublicKey = matcherKey
                newOrder.timestamp = Int64(Date().millisecondsSince1970)
                
                return Observable.create({ (subscribe) -> Disposable in
                    
                    let params = ["id" : Base58.encode(newOrder.id),
                                  "senderPublicKey" :  Base58.encode(newOrder.senderPublicKey.publicKey),
                                  "matcherPublicKey" : Base58.encode(newOrder.matcherPublicKey.publicKey),
                                  "assetPair" : newOrder.assetPair.json,
                                  "orderType" : newOrder.type.rawValue,
                                  "price" : DexList.DTO.priceAmount(price: newOrder.price,
                                                                    amountDecimals: newOrder.amountAsset.decimals,
                                                                    priceDecimals: newOrder.priceAsset.decimals),
                                  "amount" : newOrder.amount.amount,
                                  "timestamp" : newOrder.timestamp,
                                  "expiration" : newOrder.expirationTimestamp,
                                  "matcherFee" : newOrder.fee,
                                  "signature" : Base58.encode(newOrder.signature)] as [String : Any]
                    
                    NetworkManager.postRequestWithUrl(GlobalConstants.Matcher.orderBook, parameters: params, complete: { (info, error) in
                        
                        if info != nil {
                            let output = DexCreateOrder.DTO.Output(time: Date(milliseconds: newOrder.timestamp),
                                                                   orderType: newOrder.type,
                                                                   price: newOrder.price,
                                                                   amount: newOrder.amount)
                            subscribe.onNext(ResponseType(output: output, error: nil))
                        }
                        else {
                            subscribe.onNext(ResponseType(output: nil, error: error))
                        }
                        subscribe.onCompleted()
                    })
                    
                    return Disposables.create()
                })
                    
            })
            .catchError({ (error) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
            })
    }
}
