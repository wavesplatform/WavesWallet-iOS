//
//  MarketPulsePair.swift
//  DataLayer
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class MarketPulseAsset: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var iconUrl: String?
    @objc dynamic var hasScript: Bool = false
    @objc dynamic var isSponsored: Bool = false
    @objc dynamic var firstPrice: Double = 0
    @objc dynamic var lastPrice: Double = 0
    @objc dynamic var volume: Double = 0
    @objc dynamic var volumeWaves: Double = 0
}
