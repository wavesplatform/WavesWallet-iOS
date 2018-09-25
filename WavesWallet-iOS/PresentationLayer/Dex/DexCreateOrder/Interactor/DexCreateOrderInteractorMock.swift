//
//  DexCreateOrderInteractorProtocolMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexCreateOrderInteractorMock: DexCreateOrderInteractorProtocol {
   
    func createOrder(order: DexCreateOrder.DTO.Order) -> Observable<(Responce<DexCreateOrder.DTO.Output>)> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                let output = DexCreateOrder.DTO.Output(time: order.time,
                                                       orderType: order.type,
                                                       price: order.price,
                                                       amount: order.amount)
                
                subscribe.onNext(Responce<DexCreateOrder.DTO.Output>(output: output, error: nil))
            })
           
            return Disposables.create()
        })
    }
}
