//
//  DexListInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


fileprivate extension DexList.DTO.DexListModel {
    
    static func WavesBtcPair() -> DexList.DTO.DexListModel {
        let priceAsset = Environments.current.isTestNet ? "Fmg13HEHJHuZYbtJq8Da8wifJENq8uBxDuWoP9pVe2Qe" : "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS"
        return DexList.DTO.DexListModel.createPair(50, 23, "WAVES", "WAVES", "WAVES", 8, priceAsset, "Bitcoin", "BTC", 8)
    }  
    
    static func createPair(_ firstPrice: Float, _ lastPrice: Float, _ amountAsset: String, _ amountAssetName: String, _ amountTicker: String, _ amountDecimals: Int, _ priceAsset: String, _ priceAssetName: String, _ priceTicker: String, _ priceDecimals: Int) ->  DexList.DTO.DexListModel {
        
        return DexList.DTO.DexListModel(firstPrice: firstPrice, lastPrice: lastPrice, amountAsset: amountAsset, amountAssetName: amountAssetName, amountTicker: amountTicker, amountDecimals: amountDecimals, priceAsset: priceAsset, priceAssetName: priceAssetName, priceTicker: priceTicker, priceDecimals: priceDecimals)
    }
}

final class DexListInteractorMock: DexListInteractorProtocol {
    
    private static var testModels : [DexList.DTO.DexListModel] = [
        DexList.DTO.DexListModel.WavesBtcPair(),
        DexList.DTO.DexListModel.createPair(20, 43, "", "WAVES", "WAVES", 8, "", "ETH", "ETH", 8),
        DexList.DTO.DexListModel.createPair(10, 94, "", "Bitcoin", "Bitcoin", 8, "", "ETH", "ETH", 8),
        DexList.DTO.DexListModel.createPair(120, 20, "", "ETH Classic", "ETH Classic", 8, "", "IOTA", "IOTA", 8),
        DexList.DTO.DexListModel.createPair(40, 0, "", "Monero", "Monero", 8, "", "ETH", "ETH", 8),
        DexList.DTO.DexListModel.createPair(10, 10, "", "BTC Cash", "BTC Cash", 8, "", "Waves", "Waves", 8),
        DexList.DTO.DexListModel.createPair(10, 94, "", "ZCash", "ZCash", 8, "", "ETH", "ETH", 8),
        DexList.DTO.DexListModel.createPair(20, 65, "", "Bitcoin", "Bitcoin", 8, "", "NEO", "NEO", 8),
        DexList.DTO.DexListModel.createPair(200, 96, "", "NEM", "NEM", 8, "", "BTC", "BTC", 8)]
 
    
    func models() -> Observable<[DexList.DTO.DexListModel]> {
        
        return Observable.create({ (subscribe) -> Disposable in

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                subscribe.onNext(DexListInteractorMock.testModels)
            })
            return Disposables.create()
        })
    }
}
