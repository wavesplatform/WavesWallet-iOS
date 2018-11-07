//
//  WalletEncryption.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 07/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class WalletEncryption: Object {

    @objc dynamic var publicKey: String = ""    
    @objc dynamic var seedId: String = ""
    @objc dynamic var secret: String = ""

    override static func primaryKey() -> String? {
        return "publicKey"
    }
}
