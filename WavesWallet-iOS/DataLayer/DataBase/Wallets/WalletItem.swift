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
    @objc dynamic var hasBiometricEntrance: Bool = false
    @objc dynamic var isAlreadyShowLegalDisplay: Bool = false
    @objc dynamic var id: String = ""

    override static func primaryKey() -> String? {
        return "publicKey"
    }
}
