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
 
    var pair: DexTraderContainer.DTO.Pair!
    
    func displayInfo() -> Observable<(DexOrderBook.DTO.DisplayData)> {

        return Observable.create({ (subscribe) -> Disposable in
            
            NetworkManager.getOrderBook(amountAsset: self.pair.amountAsset.id, priceAsset: self.pair.priceAsset.id, complete: { (info, errorMessage) in
                if let info = info {
                    let json = JSON(info)
                    
                    self.getLastPrice({ (lastPrice) in
                        subscribe.onNext(self.getDisplayData(info: json, lastPrice: lastPrice))
                    })
                }
                else {
                    subscribe.onNext(DexOrderBook.DTO.DisplayData(asks: [], lastPrice: DexOrderBook.DTO.LastPrice.empty, bids: []))
                }
            })
            return Disposables.create()
        })
    }
    
}

//MARK: - TesData
private extension DexOrderBookInteractorMock {
    
    func getDisplayData(info: JSON, lastPrice: DexOrderBook.DTO.LastPrice) -> DexOrderBook.DTO.DisplayData {
       
        let itemsBids = info["bids"].arrayValue
        let itemsAsks = info["asks"].arrayValue
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

//        let biggestAmount: Int64 = (itemsBids + itemsAsks).map { $0["amount"].int64Value}.sorted().last ?? 0
//        let biggestAmountDecimal = Decimal(biggestAmount) / pow(10, pair.amountAsset.decimals)

        for item in itemsBids {

            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
//            let amountDeciminal = Decimal(amount.amount) / pow(10, amount.decimals)
//
//            let percent = 100 * amountDeciminal / biggestAmountDecimal
//
//            print(percent)

            let bid = DexOrderBook.DTO.BidAsk(price: price, amount: amount, orderType: .sell, percentAmount: Float(arc4random() % 100))
            bids.append(bid)
        }
        
        for item in itemsAsks {
            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
//            let percent = 100 * amount.amount / biggestAmount
//
//            print(percent)
            let ask = DexOrderBook.DTO.BidAsk(price: price, amount: amount, orderType: .buy, percentAmount: Float(arc4random() % 100))
            asks.append(ask)
        }
        
        
        return DexOrderBook.DTO.DisplayData(asks: asks.reversed(), lastPrice: lastPrice, bids: bids)
    }
    
    func getLastPrice(_ complete:@escaping(_ lastPrice: DexOrderBook.DTO.LastPrice) -> Void) {
        
        //        onst [lastAsk] = asks;
        //        const [firstBid] = bids;
        //        const sell = new BigNumber(firstBid && firstBid.price);
        //        const buy = new BigNumber(lastAsk && lastAsk.price);
        //        const percent = (sell && buy && buy.gt(0)) ? buy.minus(sell).times(100).div(buy) : new BigNumber(0);

        
        NetworkManager.getLastTraders(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id) { (items, errorMessage) in
            if let item = items?.firstObject as? NSDictionary {
                
                let info = JSON(item)
                let type = info["type"].stringValue == "buy" ? DexOrderBook.DTO.OrderType.buy :  DexOrderBook.DTO.OrderType.sell
                let lastPrice = DexOrderBook.DTO.LastPrice(price: info["price"].doubleValue, percent: 23.21, orderType: type)
                complete(lastPrice)
            }
            else {
                complete(DexOrderBook.DTO.LastPrice.empty)
            }
        }
    }
}
