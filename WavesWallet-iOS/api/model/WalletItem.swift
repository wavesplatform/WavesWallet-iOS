//
//  WalletItem.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

class WalletItem: Object {
    @objc dynamic var publicKey = ""
    @objc dynamic var name = ""
    @objc dynamic var isLoggedIn = false
    @objc dynamic var isBackedUp = false

    public var identity: String {
        return "\(publicKey)"
    }
    override static func primaryKey() -> String? {
        return "publicKey"
    }

    var address: String {
        return publicKeyAccount.address
    }

    var publicKeyAccount: PublicKeyAccount {
        return PublicKeyAccount(publicKey: Base58.decode(publicKey))
    }

    var toWallet: Wallet {
        return Wallet(name: name, publicKeyAccount: publicKeyAccount, isBackedUp: isBackedUp)
    }
}
