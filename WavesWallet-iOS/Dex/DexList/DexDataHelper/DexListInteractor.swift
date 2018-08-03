//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexListInteractorProtocol {
    func dexPairs() -> AsyncObservable<[DexList.DTO.DexListModel]>
}

final class DexListInteractor: DexListInteractorProtocol {
   
    func dexPairs() -> AsyncObservable<[DexList.DTO.DexListModel]> {
        return AsyncObservable.just([DexList.DTO.DexListModel.WavesBtcPair()])
    }
}

final class DexListInteractorMock: DexListInteractorProtocol {
   
    func dexPairs() -> AsyncObservable<[DexList.DTO.DexListModel]> {
                
        let wavesBtcPair = [DexList.DTO.DexListModel.WavesBtcPair()]
        
        let testPairs = [DexList.DTO.DexListModel(percent: 50, amountAsset: "xxx", amountAssetName: "Waves", amountDecimals: 8, amountTicker: "Waves", priceAsset: "BTC", priceAssetName: "Bitcoin", priceDecimals: 8, priceTicker: "dsd"),
                         
                         DexList.DTO.DexListModel(percent: -30, amountAsset: "xxx", amountAssetName: "Monero", amountDecimals: 8, amountTicker: "Waves", priceAsset: "BTC", priceAssetName: "ETH", priceDecimals: 8, priceTicker: "dsd"),
            
                         DexList.DTO.DexListModel(percent: 10, amountAsset: "xxx", amountAssetName: "Waves", amountDecimals: 8, amountTicker: "Waves", priceAsset: "BTC", priceAssetName: "EOS", priceDecimals: 8, priceTicker: "dsd"),
            
                         DexList.DTO.DexListModel(percent: 20, amountAsset: "xxx", amountAssetName: "ETH Classic", amountDecimals: 8, amountTicker: "Waves", priceAsset: "BTC", priceAssetName: "ZCash", priceDecimals: 8, priceTicker: "dsd"),
            
                         DexList.DTO.DexListModel(percent: 0, amountAsset: "xxx", amountAssetName: "Litecoin", amountDecimals: 8, amountTicker: "Waves", priceAsset: "BTC", priceAssetName: "TRON", priceDecimals: 8, priceTicker: "dsd"),
            
                         DexList.DTO.DexListModel(percent: 23, amountAsset: "xxx", amountAssetName: "IOTA", amountDecimals: 8, amountTicker: "Waves", priceAsset: "BTC", priceAssetName: "NEO", priceDecimals: 8, priceTicker: "dsd")]
        
       
        return AsyncObservable.just(wavesBtcPair + testPairs)
    }
}

