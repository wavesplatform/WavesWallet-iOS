//
//  DexLastTradesInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


final class DexLastTradesInteractorMock: DexLastTradesInteractorProtocol {
    
    var pair: DexTraderContainer.DTO.Pair!

    func trades() -> Observable<([DexLastTrades.DTO.Trade])> {

        return Observable.create({ (subscribe) -> Disposable in
            
            self.getLastTrades({ (trades) in
                subscribe.onNext(trades)
            })

            return Disposables.create()
        })
    }
}

//MARK: - TestData

private extension DexLastTradesInteractorMock {
    
    func getLastTrades(_ complete:@escaping(_ trades: [DexLastTrades.DTO.Trade]) -> Void) {
        
        NetworkManager.getLastTraders(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id) { (items, errorMessage) in
            
            var trades: [DexLastTrades.DTO.Trade] = []
            
            if let items = items {
                let info = JSON(items).arrayValue
                for item in info {

                    let timestamp = item["timestamp"].doubleValue
                    let time = Date(timeIntervalSince1970: timestamp / 1000)

                    let type: DexLastTrades.DTO.TradeType = item["type"] == "sell" ? .sell : .buy
                    let price = item["price"].doubleValue
                    let amount = item["amount"].doubleValue
                    let sum = price * amount
                    
                    trades.append(DexLastTrades.DTO.Trade(time: time,
                                                          price: Money(price),
                                                          amount: Money(amount),
                                                          sum: Money(sum),
                                                          type: type))
                }
            }

            complete(trades)
        }
    }
}
