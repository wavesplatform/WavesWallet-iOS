//
//  DexAssetPair.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class DexAsset: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var shortName: String = ""
    @objc dynamic var decimals: Int = 0
    
    convenience init(id: String, name: String, shortName: String, decimals: Int) {
        self.init()
        self.id = id
        self.name = name
        self.shortName = shortName
        self.decimals = decimals
    }
}

final class DexAssetPair: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var amountAsset: DexAsset!
    @objc dynamic var priceAsset: DexAsset!
    @objc dynamic var isGeneral: Bool = false
    @objc dynamic var sortLevel: Int = 0

    convenience init(id: String, amountAsset: Dex.DTO.Asset, priceAsset: Dex.DTO.Asset, isGeneral: Bool, sortLevel: Int) {
        self.init()
        self.id = id
        self.amountAsset = DexAsset(id: amountAsset.id, name: amountAsset.name, shortName: amountAsset.shortName, decimals: amountAsset.decimals)
        self.priceAsset = DexAsset(id: priceAsset.id, name: priceAsset.name, shortName: priceAsset.shortName, decimals: priceAsset.decimals)
        self.isGeneral = isGeneral
        self.sortLevel = sortLevel
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
