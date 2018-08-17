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
 
    private static var bids: [DexOrderBook.DTO.BidAsk] = []
    private static var asks: [DexOrderBook.DTO.BidAsk] = []

    func bidsAsks(_ pair: DexTraderContainer.DTO.Pair) -> Observable<(bids: [DexOrderBook.DTO.BidAsk], asks: [DexOrderBook.DTO.BidAsk])> {
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                self.loadBidsAsks(pair)
                subscribe.onNext((DexOrderBookInteractorMock.bids, DexOrderBookInteractorMock.asks))
            })
            return Disposables.create()
        })
    }
}

//MARK: - TesData
private extension DexOrderBookInteractorMock {
    
    func loadBidsAsks(_ pair: DexTraderContainer.DTO.Pair)  {
        
        let info = parseJSON(json: "OrderBookWavesBtcPair")
        let itemsBids = info["bids"].arrayValue
        let itemsAsks = info["asks"].arrayValue

        for item in itemsBids {
            let bid = DexOrderBook.DTO.BidAsk(price: item["price"].int64Value, amount: item["amount"].int64Value, amountAssetDecimal: pair.amountAsset.decimals, priceAssetDecimal: pair.priceAsset.decimals, orderType: .buy, percentAmount: 50)
            DexOrderBookInteractorMock.bids.append(bid)
        }
        
        
        for item in itemsAsks {
            let bid = DexOrderBook.DTO.BidAsk(price: item["price"].int64Value, amount: item["amount"].int64Value, amountAssetDecimal: pair.amountAsset.decimals, priceAssetDecimal: pair.priceAsset.decimals, orderType: .sell, percentAmount: 50)
            DexOrderBookInteractorMock.asks.append(bid)
        }
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
