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
                    
                    self.getLastPriceInfo({ (lastPriceInfo) in
                        subscribe.onNext(self.getDisplayData(info: json, lastPriceInfo: lastPriceInfo))
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
    
    func getDisplayData(info: JSON, lastPriceInfo: JSON?) -> DexOrderBook.DTO.DisplayData {
       
        let itemsBids = info["bids"].arrayValue
        let itemsAsks = info["asks"].arrayValue
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

        var totalSumBid: Decimal = 0
        var totalSumAsk: Decimal = 0
        
        let maxAmount = (itemsAsks + itemsBids).map({$0["amount"].int64Value}).max() ?? 0
        let maxAmountValue = decimalValue(Money(maxAmount, pair.amountAsset.decimals)).floatValue
        
        for item in itemsBids {

            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
            totalSumBid += decimalValue(price) * decimalValue(amount)
            
            let percent: Float = 100 * decimalValue(amount).floatValue / maxAmountValue

            let bid = DexOrderBook.DTO.BidAsk(price: price, amount: amount, sum: MoneyUtil.money(totalSumBid.doubleValue), orderType: .sell, percentAmount: percent)
            bids.append(bid)
        }
        
        for item in itemsAsks {
            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
            totalSumAsk += decimalValue(price) * decimalValue(amount)

            let percent: Float = 100 * decimalValue(amount).floatValue / maxAmountValue

            let ask = DexOrderBook.DTO.BidAsk(price: price, amount: amount, sum: MoneyUtil.money(totalSumAsk.doubleValue), orderType: .buy, percentAmount: percent)
            asks.append(ask)
        }
        
        
        var lastPrice = DexOrderBook.DTO.LastPrice.empty

        if let priceInfo = lastPriceInfo {
            var percent: Float = 0
            if let ask = asks.first, let bid = bids.first {
                let askValue = decimalValue(ask.price)
                let bidValue = decimalValue(bid.price)
                
                percent = ((askValue - bidValue) * 100 / bidValue).floatValue
            }
            
            let type = priceInfo["type"].stringValue == "buy" ? DexOrderBook.DTO.OrderType.buy :  DexOrderBook.DTO.OrderType.sell
            lastPrice = DexOrderBook.DTO.LastPrice(price: priceInfo["price"].doubleValue, percent: percent, orderType: type)
        }
        
        return DexOrderBook.DTO.DisplayData(asks: asks.reversed(), lastPrice: lastPrice, bids: bids)
    }
    
    func getLastPriceInfo(_ complete:@escaping(_ lastPriceInfo: JSON?) -> Void) {
        
        NetworkManager.getLastTraders(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id) { (items, errorMessage) in
            if let item = items?.firstObject as? NSDictionary {
                complete(JSON(item))
            }
            else {
                complete(nil)
            }
        }
    }
    
    func decimalValue(_ from: Money) -> Decimal {
        return Decimal(from.amount) / pow(10, from.decimals)
    }
}


fileprivate extension MoneyUtil {
    
    static func money(_ from: Double) -> Money {
        
        let decimals = getDecimals(from: from)
        let amount = Int64(from * pow(10, decimals).doubleValue)
        return Money(amount, decimals)
    }
    
    private static func getDecimals(from: Double) -> Int {
        
        let number = NSNumber(value: from)
        let resultString = number.stringValue
        
        let theScanner = Scanner(string: resultString)
        let decimalPoint = "."
        var unwanted: NSString?
        
        theScanner.scanUpTo(decimalPoint, into: &unwanted)
        
        if let unwanted = unwanted {
            return ((resultString.count - unwanted.length) > 0) ? resultString.count - unwanted.length - 1 : 0
        }
        return 0
    }
}
