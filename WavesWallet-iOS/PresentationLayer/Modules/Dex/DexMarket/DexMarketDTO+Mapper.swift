//
//  DexMarketDTO+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

extension DexMarket.DTO.Pair {
    
    init(_ market: Matcher.DTO.Market, realm: Realm) {
        
        var amountAssetName = market.amountAssetName
        var amountAssetShortName = market.amountAssetName
        
        if let asset = realm.object(ofType: Asset.self, forPrimaryKey: market.amountAsset) {
            amountAssetName = asset.displayName
            if let ticker = asset.ticker {
                amountAssetShortName = ticker
            }
        }
        
        //TODO: need remove when move on new Api
        if let ticker = DexMarket.MinersRewardToken[market.amountAsset] {
            amountAssetShortName = ticker
        }
        else if let ticker = DexMarket.WavesCommunityToken[market.amountAsset] {
            amountAssetShortName = ticker
        }
        
        var priceAssetName = market.priceAssetName
        var priceAssetShortName = market.priceAssetName
        
        if let asset = realm.object(ofType: Asset.self, forPrimaryKey: market.priceAsset) {
            priceAssetName = asset.displayName
            if let ticker = asset.ticker {
                priceAssetShortName = ticker
            }
        }
        
        //TODO: need remove when move on new Api
        if let ticker = DexMarket.MinersRewardToken[market.priceAsset] {
            priceAssetShortName = ticker
        }
        else if let ticker = DexMarket.WavesCommunityToken[market.priceAsset] {
            priceAssetShortName = ticker
        }
        
        amountAsset = .init(id: market.amountAsset,
                            name: amountAssetName,
                            shortName: amountAssetShortName,
                            decimals: market.amountAssetInfo.decimals)
        
        priceAsset = .init(id: market.priceAsset,
                            name: priceAssetName,
                            shortName: priceAssetShortName,
                            decimals: market.priceAssetInfo.decimals)
        
        
        let isGeneralAmount = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", amountAsset.id)).count > 0
        let isGeneralPrice = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", priceAsset.id)).count > 0
        
        isGeneral = isGeneralAmount && isGeneralPrice
        id = market.amountAsset + market.priceAsset
        isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id) != nil
        sortLevel = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id)?.sortLevel ?? 0
    }
}
