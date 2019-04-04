//
//  DexMyOrdersInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexMyOrdersInteractor: DexMyOrdersInteractorProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    private let repository = FactoryRepositories.instance.dexOrderBookRepository
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func myOrders() -> Observable<[DomainLayer.DTO.Dex.MyOrder]> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.MyOrder]>  in
            guard let self = self else { return Observable.empty() }
            return self.repository.myOrders(wallet: wallet,
                                             amountAsset: self.pair.amountAsset,
                                             priceAsset: self.pair.priceAsset)
                .catchError({ (error) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                    return Observable.just([])
                })
        })
    }
    
 
    func cancelOrder(order: DomainLayer.DTO.Dex.MyOrder) -> Observable<ResponseType<Bool>> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) ->  Observable<ResponseType<Bool>> in
            guard let self = self else { return Observable.empty() }
            return self.repository.cancelOrder(wallet: wallet,
                                          orderId: order.id,
                                          amountAsset: order.amountAsset.id,
                                          priceAsset: order.priceAsset.id)
                .flatMap({ (status) -> Observable<ResponseType<Bool>> in
                    return Observable.just(ResponseType(output: true, error: nil))
                })
                .catchError({ (error) -> Observable<ResponseType<Bool>> in
                    return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                })
        })
    }
}
