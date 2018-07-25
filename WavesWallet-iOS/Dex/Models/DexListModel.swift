//
//  DexListModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import SwiftyJSON

final class DexListModel {
    
    var percent: Float
    var amountAsset: String
    var amountAssetName: String
    var priceAsset: String
    var priceAssetName: String
    var amountDecimals: Int
    var priceDecimals: Int
    
    
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

