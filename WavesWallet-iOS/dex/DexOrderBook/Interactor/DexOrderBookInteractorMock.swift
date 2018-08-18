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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                subscribe.onNext(self.getDisplayData(pair))
            })
            return Disposables.create()
        })
    }
    
}

//MARK: - TesData
private extension DexOrderBookInteractorMock {
    
    func getDisplayData(_ pair: DexTraderContainer.DTO.Pair) -> DexOrderBook.DTO.DisplayData {
        let info = parseJSON(json: "OrderBookWavesBtcPair")
        let itemsBids = info["bids"].arrayValue
        let itemsAsks = info["asks"].arrayValue
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

        
        for item in itemsBids {
            let bid = DexOrderBook.DTO.BidAsk(price: item["price"].int64Value, amount: item["amount"].int64Value, amountAssetDecimal: pair.amountAsset.decimals, priceAssetDecimal: pair.priceAsset.decimals, orderType: .buy, percentAmount: 50)
            bids.append(bid)
        }
        
        for item in itemsAsks {
            let bid = DexOrderBook.DTO.BidAsk(price: item["price"].int64Value, amount: item["amount"].int64Value, amountAssetDecimal: pair.amountAsset.decimals, priceAssetDecimal: pair.priceAsset.decimals, orderType: .sell, percentAmount: 50)
            asks.append(bid)
        }
        
        let lastPrice = DexOrderBook.DTO.LastPrice(price: 0.00032666, percent: 30, orderType: .sell)
        return DexOrderBook.DTO.DisplayData(bids: bids, asks: asks, lastPrice: lastPrice)
    }

    
    func parseJSON(json fileName: String) -> JSON {
        guard let path = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return []
        }
        guard let data = try? Data(contentsOf: path) else {
            return []
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return []
        }
        
        return JSON(json)
    }
    
}
