//
//  DexListModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import SwiftyJSON

enum DexTypes {
    enum DTO {}
    
    enum State {
        case isLoading
        case normal
    }
}

extension DexTypes.DTO {

    struct DexListModel {
        
        let percent: Float
        let amountAsset: String
        let amountAssetName: String
        let priceAsset: String
        let priceAssetName: String
        let amountDecimals: Int
        let priceDecimals: Int
        
        
        init(json: JSON) {
            percent = 30
            amountAsset = "amount Asset"
            amountAssetName = "Asset Name"
            priceAsset = "price Asset"
            priceAssetName = "Asset Name"
            amountDecimals = 8
            priceDecimals = 8
        }
        
        init(percent: Float, amountAsset: String, amountAssetName: String, priceAsset: String, priceAssetName: String,
             amountDecimals: Int, priceDecimals: Int) {
            
            self.percent = percent
            self.amountAsset = amountAsset
            self.amountAssetName = amountAssetName
            self.priceAsset = priceAsset
            self.priceAssetName = priceAssetName
            self.amountDecimals = amountDecimals
            self.priceDecimals = priceDecimals
        }
    }
}

