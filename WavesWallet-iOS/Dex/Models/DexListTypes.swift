//
//  DexListModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexList {
    enum DTO {}
    enum ViewModel {}

    enum State {
        case isLoading
        case normal
    }
}

extension DexList.DTO {

    struct DexListModel: Hashable {
        
        let firstPrice: Float
        let lastPrice: Float
        let amountAsset: String
        let amountAssetName: String
        let amountTicker: String
        let amountDecimals: Int
        let priceAsset: String
        let priceAssetName: String
        let priceTicker: String
        let priceDecimals: Int
        
        init(firstPrice: Float, lastPrice: Float, amountAsset: String, amountAssetName: String, amountDecimals: Int, amountTicker: String, priceAsset: String, priceAssetName: String, priceDecimals: Int, priceTicker: String) {

            self.firstPrice = firstPrice
            self.lastPrice = lastPrice
            self.amountAsset = amountAsset
            self.amountAssetName = amountAssetName
            self.amountDecimals = amountDecimals
            self.amountTicker = amountTicker
            self.priceAsset = priceAsset
            self.priceAssetName = priceAssetName
            self.priceDecimals = priceDecimals
            self.priceTicker = priceTicker
        }
        
        static func WavesBtcPair() -> DexListModel {
            
            let priceAsset = Environments.current.isTestNet ? "Fmg13HEHJHuZYbtJq8Da8wifJENq8uBxDuWoP9pVe2Qe" : "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS"
            
            return DexListModel(firstPrice: 50, lastPrice: 23, amountAsset: "WAVES", amountAssetName: "WAVES", amountDecimals: 8, amountTicker: "WAVES", priceAsset: priceAsset, priceAssetName: "Bitcoin", priceDecimals: 8, priceTicker: "BTC")

        }
    }
}

extension DexList.ViewModel {
    struct Section: Mutating {
        enum Kind {
            case header
            case row
        }
        
        let kind: Kind
        var items: [Row]
    }
    
    enum Row {
        case header
        case models(DexList.DTO.DexListModel)
    }
}



