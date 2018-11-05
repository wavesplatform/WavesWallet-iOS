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
    private let disposeBag = DisposeBag()
    
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<(ResponseType<DexCreateOrder.DTO.Output>)> {
       
        return Observable.zip(auth.authorizedWallet(), getMatcherPublicKey()).flatMap({(wallet, matcherResponse) -> Observable<(ResponseType<DexCreateOrder.DTO.Output>)> in
            
            if let matcher = matcherResponse.output {
                var newOrder = order
                newOrder.senderPrivateKey = wallet.privateKey
                newOrder.senderPublicKey = wallet.publicKey
                newOrder.matcherPublicKey = matcher
                
                return Observable.create({ (subscribe) -> Disposable in

                    
                    let assetPair = ["amountAsset" : newOrder.amountAsset.id,
                                     "priceAsset" : newOrder.priceAsset.id]

                    let jsonData = try! JSONSerialization.data(withJSONObject: assetPair, options: [])
                    
                    guard let assetPairStr = String(data: jsonData, encoding: .utf8) else { return Disposables.create() }
                    
                    let params = ["id" : Base58.encode(newOrder.id),
                                  "senderPublicKey" :  Base58.encode(newOrder.senderPublicKey.publicKey),
                                  "matcherPublicKey" : Base58.encode(newOrder.matcherPublicKey.publicKey),
                                  "assetPair" : assetPairStr,
                                  "price" : newOrder.price.amount,
                                  "amount" : newOrder.price.amount,
                                  "timestamp" : newOrder.timestamp,
                                  "expiration" : newOrder.expiration,
                                  "matcherFee" : newOrder.fee,
                                  "signature" : newOrder.signature] as [String : Any]
                    
                    NetworkManager.postRequestWithUrl(GlobalConstants.Matcher.matcher, parameters: params, complete: { (info, error) in
                        
                        print(info, error)
                        
//                        let output = DexCreateOrder.DTO.Output(time: Date(milliseconds: order.timestamp),
//                                                               orderType: order.type,
//                                                               price: order.price,
//                                                               amount: order.amount)
//                        subscribe.onNext(ResponseType<DexCreateOrder.DTO.Output>(output: output, error: nil))

                    })
                    
                    return Disposables.create()
                })
            }
            else {
                return Observable.just(ResponseType(output: nil, error: matcherResponse.error))
            }
        })
    }
    
    private func getMatcherPublicKey() -> Observable<ResponseType<PublicKeyAccount>> {
        
        return Observable.create({ (subscribe) -> Disposable in
        
            NetworkManager.getRequestWithUrl(GlobalConstants.Matcher.matcher, parameters: nil) { (info, error) in
                if let info = info {
                    let matcherPublicKey = PublicKeyAccount(publicKey: Base58.decode(info.stringValue))
                    subscribe.onNext(ResponseType(output: matcherPublicKey, error: nil))
                }
                else {
                    subscribe.onNext(ResponseType(output: nil, error: error))
                }
                subscribe.onCompleted()
            }
            
            return Disposables.create()
        })
    }
}
