//
//  IssueTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

final class IssueTransaction: Transaction {

    @objc dynamic var signature: String? = nil
    @objc dynamic var assetId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var quantity: Int64 = 0
    @objc dynamic var reissuable: Bool = false
    @objc dynamic var decimals: Int = 0
    @objc dynamic var assetDescription: String = ""
    @objc dynamic var script: String? = nil
}
