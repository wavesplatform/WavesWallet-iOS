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

final class DexAssetPair: Object {
   
    @objc dynamic var amountAssetID: String = ""
    @objc dynamic var amountAssetName: String = ""
    @objc dynamic var amountAssetDecimals: Int = 0
    
    @objc dynamic var priceAssetID: String = ""
    @objc dynamic var priceAssetName: String = ""
    @objc dynamic var priceAssetDecimals: Int = 0

    convenience init(_ info: JSON) {
        self.init()
        amountAssetID = info["amountAsset"].stringValue
        amountAssetName = info["amountAssetName"].stringValue
        amountAssetDecimals = info["amountAssetInfo"]["decimals"].intValue
        
        priceAssetID = info["priceAsset"].stringValue
        priceAssetName = info["priceAssetName"].stringValue
        priceAssetDecimals = info["priceAssetInfo"]["decimals"].intValue
    }
    
    var id: String {
        return amountAssetID + priceAssetID
    }
}
