//
//  WalletEncryption.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07/11/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift

class WalletEncryptionRealm: Object {

    @objc dynamic var publicKey: String = ""    
    @objc dynamic var seedId: String = ""
    @objc dynamic var secret: String? = ""

    override static func primaryKey() -> String? {
        return "publicKey"
    }
}
