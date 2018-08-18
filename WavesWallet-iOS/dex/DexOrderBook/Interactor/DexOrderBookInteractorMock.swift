//
//  DexOrderBookInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


final class DexOrderBookInteractorMock: DexOrderBookInteractorProtocol {
 
    func displayInfo(_ pair: DexTraderContainer.DTO.Pair) -> Observable<(DexOrderBook.DTO.DisplayData)> {

        return Observable.create({ (subscribe) -> Disposable in
            
            NetworkManager.getOrderBook(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id, complete: { (info, errorMessage) in
                if let info = info {
                    let json = JSON(info)
                    subscribe.onNext(self.getDisplayData(info: json, pair: pair))
                }
                else {
                    let lastPrice = DexOrderBook.DTO.LastPrice(price: 0, percent: 0, orderType: .none)
                    subscribe.onNext(DexOrderBook.DTO.DisplayData(asks: [], bids: [], lastPrice: lastPrice))
                }
            })
            return Disposables.create()
        })
    }
    
}

//MARK: - TesData
private extension DexOrderBookInteractorMock {
    
    func getDisplayData(info: JSON, pair: DexTraderContainer.DTO.Pair) -> DexOrderBook.DTO.DisplayData {
       
        let itemsBids = info["bids"].arrayValue
        let itemsAsks = info["asks"].arrayValue
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

        for item in itemsBids {

            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            let bid = DexOrderBook.DTO.BidAsk(price: price, amount: amount, orderType: .sell, percentAmount: 35.2)

            bids.append(bid)
        }
        
        for item in itemsAsks {
            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            let ask = DexOrderBook.DTO.BidAsk(price: price, amount: amount, orderType: .buy, percentAmount: 54.43)

            asks.append(ask)
        }
        
        let lastPrice = DexOrderBook.DTO.LastPrice(price: 0.00032666, percent: 30, orderType: .sell)
        return DexOrderBook.DTO.DisplayData(asks: asks.reversed(), bids: bids, lastPrice: lastPrice)
    }
    
}
