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
    @objc dynamic var publicKey: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var isLoggedIn: Bool = false
    @objc dynamic var isBackedUp: Bool = false
    @objc dynamic var address: String = ""
    @objc dynamic var secret: String = ""
    @objc dynamic var hasBiometricEntrance: Bool = false

    public var identity: String {
        return "\(publicKey)"
    }
    override static func primaryKey() -> String? {
        return "publicKey"
    }


    var publicKeyAccount: PublicKeyAccount {
        return PublicKeyAccount(publicKey: Base58.decode(publicKey))
    }

    var toWallet: Wallet {
        return Wallet(name: name, publicKeyAccount: publicKeyAccount, isBackedUp: isBackedUp)
    }
}
