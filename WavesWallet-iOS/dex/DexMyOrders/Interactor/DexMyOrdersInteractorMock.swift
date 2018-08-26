//
//  DexMyOrdersInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexMyOrdersInteractorMock: DexMyOrdersInteractorProtocol {
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func myOrders() -> Observable<([DexMyOrders.DTO.Order])> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
          
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                
                var orders : [DexMyOrders.DTO.Order] = []
                
                let today = Date()
                let date1 = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                let date2 = Calendar.current.date(byAdding: .day, value: 2, to: today)!
                let date3 = Calendar.current.date(byAdding: .day, value: 3, to: today)!

                var statuses: [DexMyOrders.DTO.Status] = [.accepted,
                                                          .partiallyFilled,
                                                          .cancelled,
                                                          .filled]
                
                for _ in 0..<10 {
                    let status = statuses[Int(arc4random() % UInt32(statuses.count))]
                    orders.append(DexMyOrders.DTO.Order(time: date1.addingTimeInterval(Double(arc4random() % 1000)), status: status, price: Money(Double(arc4random() % 200)), amount: Money(Double(arc4random() % 300)), type: arc4random() % 2 == 0 ? .sell : .buy))
                }
                
                for _ in 0..<10 {
                    let status = statuses[Int(arc4random() % UInt32(statuses.count))]
                    orders.append(DexMyOrders.DTO.Order(time: date2.addingTimeInterval(Double(arc4random() % 2000)), status: status, price: Money(Double(arc4random() % 200)), amount: Money(Double(arc4random() % 300)), type: arc4random() % 2 == 0 ? .sell : .buy))
                }
                
                for _ in 0..<10 {
                    let status = statuses[Int(arc4random() % UInt32(statuses.count))]
                    orders.append(DexMyOrders.DTO.Order(time: date3.addingTimeInterval(Double(arc4random() % 3000)), status: status, price: Money(Double(arc4random() % 200)), amount: Money(Double(arc4random() % 300)), type: arc4random() % 2 == 0 ? .sell : .buy))
                }
                
                subscribe.onNext(orders)
            })
            return Disposables.create()
        })
    }
    
    func deleteOrder(order: DexMyOrders.DTO.Order) {
        
    }
}
