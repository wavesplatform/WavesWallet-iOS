//
//  SeedItem.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift
import WavesSDKCrypto
import WavesSDKExtensions
import DomainLayer
import Extensions

class SeedItem: Object {
    @objc dynamic var publicKey: String = ""
    @objc dynamic var seed: String = ""
    @objc dynamic var address: String = ""

    public var identity: String {
        return "\(publicKey)"
    }
    override static func primaryKey() -> String? {
        return "publicKey"
    }
}
