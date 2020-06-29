//
//  TransferTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class TransferTransactionRealm: TransactionRealm {
    
    @objc dynamic var recipient: String = ""
    @objc dynamic var assetId: String? = nil
    @objc dynamic var feeAssetId: String? = nil
    @objc dynamic var feeAsset: String? = nil    
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var attachment: String? = nil
}
