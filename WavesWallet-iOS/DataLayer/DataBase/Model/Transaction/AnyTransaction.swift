//
//  AnyTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 03.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class AnyTransaction: Object {

    @objc dynamic var transaction: Transaction?
    @objc dynamic var id: String = ""

    public override class func primaryKey() -> String? {
        return "id"
    }
}
