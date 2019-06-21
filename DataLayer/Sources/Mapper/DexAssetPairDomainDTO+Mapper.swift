//
//  DexMarketDomainDTO+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/27/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift
import WavesSDK
import DomainLayer


//TODO: Constants
private enum Constants {
    static let MinersRewardToken = ["4uK8i4ThRGbehENwa6MxyLtxAjAo1Rj9fduborGExarC" : "MRT"]
    static let WavesCommunityToken = ["DHgwrRvVyqJsepd32YbBqUeDH4GJ1N984X8QoekjgH8J" : "WCT"]
}

extension DomainLayer.DTO.Dex.SmartPair {
    
    init(_ pair: DexAssetPair, isChecked: Bool) {
        
        let amountAsset = DomainLayer.DTO.Dex.Asset(id: pair.amountAsset.id,
                                                    name: pair.amountAsset.name,
                                                    shortName: pair.amountAsset.shortName,
                                                    decimals: pair.amountAsset.decimals)
        
        let priceAsset = DomainLayer.DTO.Dex.Asset(id: pair.priceAsset.id,
                                                   name: pair.priceAsset.name,
                                                   shortName: pair.priceAsset.shortName,
                                                   decimals: pair.priceAsset.decimals)
        
        
        self.init(id: pair.id,
                  amountAsset: amountAsset,
                  priceAsset: priceAsset,
                  isChecked: isChecked,
                  isGeneral: pair.isGeneral,
                  sortLevel: pair.sortLevel)        
    }
}


extension DomainLayer.DTO.Dex.SmartPair {
    
    init(_ market: MatcherService.DTO.Market, realm: Realm) {
        
        var amountAssetName = market.amountAssetName
        var amountAssetShortName = market.amountAssetName
        
        if let asset = realm.object(ofType: Asset.self, forPrimaryKey: market.amountAsset) {
            amountAssetName = asset.displayName
            if let ticker = asset.ticker {
                amountAssetShortName = ticker
            }
        }
        
        //TODO: need remove when move on new Api
        if let ticker = Constants.MinersRewardToken[market.amountAsset] {
            amountAssetShortName = ticker
        }
        else if let ticker = Constants.WavesCommunityToken[market.amountAsset] {
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
        if let ticker = Constants.MinersRewardToken[market.priceAsset] {
            priceAssetShortName = ticker
        }
        else if let ticker = Constants.WavesCommunityToken[market.priceAsset] {
            priceAssetShortName = ticker
        }
        
        let amountAsset: DomainLayer.DTO.Dex.Asset = .init(id: market.amountAsset,
                                                           name: amountAssetName,
                                                           shortName: amountAssetShortName,
                                                           decimals: market.amountAssetInfo?.decimals ?? 0)
        
        let priceAsset: DomainLayer.DTO.Dex.Asset = .init(id: market.priceAsset,
                                                          name: priceAssetName,
                                                          shortName: priceAssetShortName,
                                                          decimals: market.priceAssetInfo?.decimals ?? 0)
        
        
        let isGeneralAmount = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", amountAsset.id)).count > 0
        let isGeneralPrice = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", priceAsset.id)).count > 0
        
        let isGeneral = isGeneralAmount && isGeneralPrice
        let id = market.amountAsset + market.priceAsset
        let isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id) != nil
        let sortLevel = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id)?.sortLevel ?? 0
        
        
        self.init(id: id,
                  amountAsset: amountAsset,
                  priceAsset: priceAsset,
                  isChecked: isChecked,
                  isGeneral: isGeneral,
                  sortLevel: sortLevel)
    }
}
