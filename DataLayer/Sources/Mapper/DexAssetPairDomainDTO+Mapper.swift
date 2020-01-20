//
//  DexMarketDomainDTO+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/27/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift
import WavesSDK
import DomainLayer

public extension DomainLayer.DTO.Dex.SmartPair {
    
    init(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, isChecked: Bool, isGeneral: Bool, sortLevel: Int) {
        
        let id = amountAsset.id + priceAsset.id

        self.init(id: id,
                  amountAsset: amountAsset,
                  priceAsset: priceAsset,
                  isChecked: isChecked,
                  isGeneral: isGeneral,
                  sortLevel: sortLevel)
    }
    
}

extension DomainLayer.DTO.Dex.SmartPair {
    
    init(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, realm: Realm) {
        
        let id = amountAsset.id + priceAsset.id
        let isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id) != nil
        let sortLevel = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id)?.sortLevel ?? 0
        
        let isGeneralAmount = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", amountAsset.id)).count > 0
        let isGeneralPrice = realm.objects(Asset.self)
            .filter(NSPredicate(format: "id == %@ AND isGeneral == true", priceAsset.id)).count > 0
        let isGeneral = isGeneralAmount && isGeneralPrice

        self.init(id: id,
                  amountAsset: amountAsset,
                  priceAsset: priceAsset,
                  isChecked: isChecked,
                  isGeneral: isGeneral,
                  sortLevel: sortLevel)
    }
}
