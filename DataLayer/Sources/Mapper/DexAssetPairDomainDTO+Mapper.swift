//
//  DexMarketDomainDTO+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/27/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RealmSwift
import WavesSDK

public extension DomainLayer.DTO.Dex.SmartPair {
    init(amountAsset: Asset,
         priceAsset: Asset,
         isChecked: Bool,
         isGeneral: Bool,
         sortLevel: Int) {
        let id = amountAsset.id + priceAsset.id

        self.init(id: id,
                  amountAsset: amountAsset,
                  priceAsset: priceAsset,
                  isChecked: isChecked,
                  isGeneral: isGeneral,
                  sortLevel: sortLevel)
    }
}

// TODO: Remove call realm
extension DomainLayer.DTO.Dex.SmartPair {
    init(amountAsset: Asset, priceAsset: Asset, realm: Realm) {
        let id = amountAsset.id + priceAsset.id
        let isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id) != nil
        let sortLevel = realm.object(ofType: DexAssetPair.self, forPrimaryKey: id)?.sortLevel ?? 0

        let isGeneral = amountAsset.isGeneral && priceAsset.isGeneral

        self.init(id: id,
                  amountAsset: amountAsset,
                  priceAsset: priceAsset,
                  isChecked: isChecked,
                  isGeneral: isGeneral,
                  sortLevel: sortLevel)
    }
}
