//
//  Asset.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class Asset: Object, AssetProtocol {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var precision: Int = 0
    @objc dynamic var descriptionAsset: String = ""
    @objc dynamic var height: Int64 = 0
    @objc dynamic var timestamp: String = ""
    @objc dynamic var sender: String = ""
    @objc dynamic var quantity: Int64 = 0
    @objc dynamic var ticker: String?
    @objc dynamic var isReissuable: Bool = false
    @objc dynamic var isSpam: Bool = false
    @objc dynamic var isFiat: Bool = false
    @objc dynamic var isGeneral: Bool = false
    @objc dynamic var isMyAsset: Bool = false
    @objc dynamic var isGateway: Bool = false

    override class func primaryKey() -> String? {
        return "id"
    }
}
