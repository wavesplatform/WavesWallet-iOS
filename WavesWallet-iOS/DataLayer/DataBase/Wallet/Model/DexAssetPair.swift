//
//  DexAssetPair.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

final class DexAsset: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var decimals: Int = 0
    
    convenience init(id: String, name: String, decimals: Int) {
        self.init()
        self.id = id
        self.name = name
        self.decimals = decimals
    }
}

final class DexAssetPair: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var amountAsset: DexAsset!
    @objc dynamic var priceAsset: DexAsset!
    @objc dynamic var isGeneral: Bool = false

    convenience init(id: String, amountAsset: DexMarket.DTO.Asset, priceAsset: DexMarket.DTO.Asset, isGeneral: Bool) {
        self.init()
        self.id = id
        self.amountAsset = DexAsset(id: amountAsset.id, name: amountAsset.name, decimals: amountAsset.decimals)
        self.priceAsset = DexAsset(id: priceAsset.id, name: priceAsset.name, decimals: priceAsset.decimals)
        self.isGeneral = isGeneral
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
