//
//  AssetBalanceSettings.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class AssetBalanceSettings: Object, AssetBalanceSettingsProtocol {

    @objc dynamic var assetId: String = ""
    @objc dynamic var sortLevel: Float = 0
    @objc dynamic var isHidden = false
    @objc dynamic var isFavorite = false

    override class func primaryKey() -> String? {
        return "assetId"
    }
}
