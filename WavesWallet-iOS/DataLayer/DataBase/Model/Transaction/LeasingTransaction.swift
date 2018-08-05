//
//  LeasingTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class LeasingTransaction: Object {
    @objc dynamic var type: Int = 0
    @objc dynamic var id: String = ""
    @objc dynamic var sender: String = ""
    @objc dynamic var senderPublicKey: String = ""
    @objc dynamic var fee: Int64 = 0
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var signature: String = ""
    @objc dynamic var version: Int = 0
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var recipient: String = ""    
    @objc dynamic var height: Int64 = 0
    @objc dynamic var modified: Date = Date()

    public override class func primaryKey() -> String? {
        return "id"
    }
}
