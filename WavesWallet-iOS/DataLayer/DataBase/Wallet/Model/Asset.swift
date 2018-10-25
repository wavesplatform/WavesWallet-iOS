//
//  Asset.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class Asset: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var wavesId: String?
    @objc dynamic var gatewayId: String?
    @objc dynamic var displayName: String = ""
    @objc dynamic var precision: Int = 0
    @objc dynamic var descriptionAsset: String = ""
    @objc dynamic var height: Int64 = 0
    @objc dynamic var timestamp: Date = Date()
    @objc dynamic var sender: String = ""
    @objc dynamic var quantity: Int64 = 0
    @objc dynamic var ticker: String?
    @objc dynamic var modified: Date = Date()
    @objc dynamic var isReusable: Bool = false
    @objc dynamic var isSpam: Bool = false
    @objc dynamic var isFiat: Bool = false
    @objc dynamic var isGeneral: Bool = false
    @objc dynamic var isMyWavesToken: Bool = false
    @objc dynamic var isWavesToken: Bool = false    
    @objc dynamic var isGateway: Bool = false
    @objc dynamic var isWaves: Bool = false
    @objc dynamic var regularExpression: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }
    
    var icon: String {
        return ticker ?? displayName
    }
}
