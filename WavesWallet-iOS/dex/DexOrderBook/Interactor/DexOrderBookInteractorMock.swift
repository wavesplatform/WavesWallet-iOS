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

private enum Constanst {
    static let priceAssetBalance: Int64 = 652333333240
    static let amountAssetBalance: Int64 = 31433333240
}

final class DexOrderBookInteractorMock: DexOrderBookInteractorProtocol {
 
    var pair: DexTraderContainer.DTO.Pair!
    
    func displayInfo() -> Observable<(DexOrderBook.DTO.DisplayData)> {

        return Observable.create({ (subscribe) -> Disposable in
            
            let header = DexOrderBook.ViewModel.Header(amountName: self.pair.amountAsset.name, priceName: self.pair.priceAsset.name, sumName: self.pair.priceAsset.name)
            
            NetworkManager.getOrderBook(amountAsset: self.pair.amountAsset.id, priceAsset: self.pair.priceAsset.id, complete: { (info, errorMessage) in
                if let info = info {
                    let json = JSON(info)
                    
                    self.getLastPriceInfo({ (lastPriceInfo) in
                        subscribe.onNext(self.getDisplayData(info: json, lastPriceInfo: lastPriceInfo, header: header))
                    })
                }
                else {
                    subscribe.onNext(DexOrderBook.DTO.DisplayData(asks: [], lastPrice: DexOrderBook.DTO.LastPrice.empty, bids: [],
                                                                  header: header,
                                                                  availablePriceAssetBalance: Money(0 ,self.pair.priceAsset.decimals),
                                                                  availableAmountAssetBalance: Money(0, self.pair.amountAsset.decimals)))
                }
            })
            return Disposables.create()
        })
    }
    
}

//MARK: - TesData
private extension DexOrderBookInteractorMock {
    
    func getDisplayData(info: JSON, lastPriceInfo: JSON?, header: DexOrderBook.ViewModel.Header) -> DexOrderBook.DTO.DisplayData {
       
        let itemsBids = info["bids"].arrayValue
        let itemsAsks = info["asks"].arrayValue
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

        var totalSumBid: Decimal = 0
        var totalSumAsk: Decimal = 0
        
        let maxAmount = (itemsAsks + itemsBids).map({$0["amount"].int64Value}).max() ?? 0
        let maxAmountValue = Money(maxAmount, pair.amountAsset.decimals).floatValue
        
        for item in itemsBids {

            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
            totalSumBid += price.decimalValue * amount.decimalValue
            
            let percent: Float = 100 * amount.floatValue / maxAmountValue

            let bid = DexOrderBook.DTO.BidAsk(price: price,
                                              amount: amount,
                                              sum: Money(value: totalSumBid, price.decimals),
                                              orderType: .sell,
                                              percentAmount: percent)
            bids.append(bid)
        }
        
        for item in itemsAsks {
            let price = Money(item["price"].int64Value, pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
            totalSumAsk += price.decimalValue * amount.decimalValue

            let percent: Float = 100 * amount.floatValue / maxAmountValue

            let ask = DexOrderBook.DTO.BidAsk(price: price,
                                              amount: amount,
                                              sum: Money(value: totalSumAsk, price.decimals),
                                              orderType: .buy,
                                              percentAmount: percent)
            asks.append(ask)
        }
        
        
        var lastPrice = DexOrderBook.DTO.LastPrice.empty

        if let priceInfo = lastPriceInfo {
            var percent: Float = 0
            if let ask = asks.first, let bid = bids.first {
                let askValue = ask.price.decimalValue
                let bidValue = bid.price.decimalValue
                
                percent = ((askValue - bidValue) * 100 / bidValue).floatValue
            }
            
            let type = priceInfo["type"].stringValue == "buy" ? DexOrderBook.DTO.OrderType.buy :  DexOrderBook.DTO.OrderType.sell
            let price = Money(value: Decimal(priceInfo["price"].doubleValue), pair.priceAsset.decimals)
            
            lastPrice = DexOrderBook.DTO.LastPrice(price: price, percent: percent, orderType: type)
        }
        
        
        return DexOrderBook.DTO.DisplayData(asks: asks.reversed(), lastPrice: lastPrice, bids: bids, header: header,
                                            availablePriceAssetBalance: Money(Constanst.priceAssetBalance ,self.pair.priceAsset.decimals),
                                            availableAmountAssetBalance: Money(Constanst.amountAssetBalance, self.pair.amountAsset.decimals))
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
}
