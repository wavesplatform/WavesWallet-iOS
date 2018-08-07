//
//  DexListInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


fileprivate extension DexList.DTO.Pair {
    
    static func WavesBtcPair() -> DexList.DTO.Pair {
        let priceAsset = Environments.current.isTestNet ? "Fmg13HEHJHuZYbtJq8Da8wifJENq8uBxDuWoP9pVe2Qe" : "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS"
        return DexList.DTO.Pair.createPair(50, 23, "WAVES", "WAVES", "WAVES", 8, priceAsset, "Bitcoin", "BTC", 8)
    }  
    
    static func createPair(_ firstPrice: Float, _ lastPrice: Float, _ amountAsset: String, _ amountAssetName: String, _ amountTicker: String, _ amountDecimals: Int, _ priceAsset: String, _ priceAssetName: String, _ priceTicker: String, _ priceDecimals: Int) ->  DexList.DTO.Pair {
        
        return DexList.DTO.Pair(firstPrice: firstPrice, lastPrice: lastPrice, amountAsset: amountAsset, amountAssetName: amountAssetName, amountTicker: amountTicker, amountDecimals: amountDecimals, priceAsset: priceAsset, priceAssetName: priceAssetName, priceTicker: priceTicker, priceDecimals: priceDecimals)
    }
}

final class DexListInteractorMock: DexListInteractorProtocol {
    
    private static var testModels : [DexList.DTO.Pair] = [
        DexList.DTO.Pair.WavesBtcPair(),
        DexList.DTO.Pair.createPair(20, 43, "", "WAVES", "WAVES", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(10, 94, "", "Bitcoin", "Bitcoin", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(120, 20, "", "ETH Classic", "ETH Classic", 8, "", "IOTA", "IOTA", 8),
        DexList.DTO.Pair.createPair(40, 0.1, "", "Monero", "Monero", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(10, 10, "", "BTC Cash", "BTC Cash", 8, "", "Waves", "Waves", 8),
        DexList.DTO.Pair.createPair(10, 94, "", "ZCash", "ZCash", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(20, 65, "", "Bitcoin", "Bitcoin", 8, "", "NEO", "NEO", 8),
        DexList.DTO.Pair.createPair(200, 96, "", "NEM", "NEM", 8, "", "BTC", "BTC", 8)]
 
    
    func pairs() -> Observable<[DexList.DTO.Pair]> {
        
        return Observable.create({ (subscribe) -> Disposable in

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                subscribe.onNext(DexListInteractorMock.testModels)
            })
            return Disposables.create()
        })
    }
}
