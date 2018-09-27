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

private enum Constanst {
    static let priceAssetBalance: Int64 = 652333333240
    static let amountAssetBalance: Int64 = 31433333240
}

final class DexLastTradesInteractorMock: DexLastTradesInteractorProtocol {
    
    var pair: DexTraderContainer.DTO.Pair!

    func displayInfo() -> Observable<(DexLastTrades.DTO.DisplayData)> {

        return Observable.create({ (subscribe) -> Disposable in
            
            self.getLastTrades({ (trades) in
                self.getLastSellBuy({ (lastSell, lastBuy) in
                    
                    let availableAmountAssetBalance =  Money(Constanst.amountAssetBalance, self.pair.amountAsset.decimals)
                    let availablePriceAssetBalance =  Money(Constanst.priceAssetBalance, self.pair.priceAsset.decimals)

                    let display = DexLastTrades.DTO.DisplayData(trades: trades, lastSell: lastSell, lastBuy: lastBuy,
                                                                availableAmountAssetBalance: availableAmountAssetBalance,
                                                                availablePriceAssetBalance: availablePriceAssetBalance)
                    subscribe.onNext(display)
                })
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

                    let type: Dex.DTO.OrderType = item["type"] == "sell" ? .sell : .buy
                    let price = Decimal(item["price"].doubleValue)
                    let amount = Decimal(item["amount"].doubleValue)
                    let sum = price * amount
                    
                    trades.append(DexLastTrades.DTO.Trade(time: time,
                                                          price: Money(value: price, self.pair.priceAsset.decimals),
                                                          amount: Money(value: amount, self.pair.amountAsset.decimals),
                                                          sum: Money(value: sum, self.pair.priceAsset.decimals),
                                                          type: type))
                }
            }

            complete(trades)
        }
    }
    
    func getLastSellBuy(_ complete:@escaping(_ lastSell: DexLastTrades.DTO.SellBuyTrade?, _ lastBuy: DexLastTrades.DTO.SellBuyTrade?) -> Void) {
        
        NetworkManager.getOrderBook(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id) { (items, errorMessage) in
            
            var sell: DexLastTrades.DTO.SellBuyTrade?
            var buy: DexLastTrades.DTO.SellBuyTrade?

            if let items = items {
                let info = JSON(items)
                
                if let bid = info["bids"].arrayValue.first {

                    sell = DexLastTrades.DTO.SellBuyTrade(price: Money((bid["price"]).int64Value, self.pair.priceAsset.decimals),
                                                          type: .sell)
                }
                
                if let ask = info["asks"].arrayValue.first {
                    buy = DexLastTrades.DTO.SellBuyTrade(price: Money((ask["price"]).int64Value, self.pair.priceAsset.decimals),
                                                         type: .buy)
                }
            }

            complete(sell, buy)
        }
    }
}
