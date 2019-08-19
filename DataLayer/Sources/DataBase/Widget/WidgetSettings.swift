//
//  WidgetSettings.swift
//  DataLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class WidgetSettings: Object {
    
    @objc dynamic var isDarkStyle: Bool = false
    @objc dynamic var interval: Int = 0
    let assets: List<WidgetSettingsAsset> = .init()
}

class WidgetSettingsAsset: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var icon: WidgetSettingsAssetIcon!
    @objc dynamic var amountAsset: String = ""
    @objc dynamic var priceAsset: String = ""
}

class WidgetSettingsAssetIcon: Object {
    @objc dynamic var assetId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var url: String? = nil
    @objc dynamic var isSponsored: Bool = false
    @objc dynamic var hasScript: Bool = false
}
