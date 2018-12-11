//
//  DexMarketDTO+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension DexMarket.DTO.Pair {
    
    init(_ json: JSON, realm: Realm) {
        
        let amountAssetId = json["amountAsset"].stringValue
        var amountAssetName = json["amountAssetName"].stringValue
        var amountAssetShortName = json["amountAssetName"].stringValue
        
        if let asset = realm.object(ofType: Asset.self, forPrimaryKey: amountAssetId) {
            amountAssetName = asset.displayName
            if let ticker = asset.ticker {
                amountAssetShortName = ticker
            }
        }
        
        //TODO: need remove when move on new Api
        if let ticker = DexMarket.MinersRewardToken[amountAssetId] {
            amountAssetShortName = ticker
        }
        else if let ticker = DexMarket.WavesCommunityToken[amountAssetId] {
            amountAssetShortName = ticker
        }
        
        let priceAssetId = json["priceAsset"].stringValue
        var priceAssetName = json["priceAssetName"].stringValue
        var priceAssetShortName = json["priceAssetName"].stringValue
        
        if let asset = realm.object(ofType: Asset.self, forPrimaryKey: priceAssetId) {
            priceAssetName = asset.displayName
            if let ticker = asset.ticker {
                priceAssetShortName = ticker
            }
        }
        
        //TODO: need remove when move on new Api
        if let ticker = DexMarket.MinersRewardToken[priceAssetId] {
            priceAssetShortName = ticker
        }
        else if let ticker = DexMarket.WavesCommunityToken[priceAssetId] {
            priceAssetShortName = ticker
        }
        
        amountAsset = Dex.DTO.Asset(id: amountAssetId,
                                    name: amountAssetName,
                                    shortName: amountAssetShortName,
                                    decimals: json["amountAssetInfo"]["decimals"].intValue)
        
        priceAsset = Dex.DTO.Asset(id: priceAssetId,
                                    name: priceAssetName,
                                    shortName: priceAssetShortName,
                                    decimals: json["priceAssetInfo"]["decimals"].intValue)
        
        
        let isGeneralAmount = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", amountAsset.id)).count > 0
        let isGeneralPrice = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", priceAsset.id)).count > 0
        
        isGeneral = isGeneralAmount && isGeneralPrice
        id = amountAssetId + priceAssetId
        isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id) != nil
        sortLevel = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id)?.sortLevel ?? 0
    }
}
