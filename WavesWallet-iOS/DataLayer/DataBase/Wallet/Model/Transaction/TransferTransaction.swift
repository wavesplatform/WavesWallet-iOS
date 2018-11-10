//
//  TransferTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class TransferTransaction: Transaction {

    @objc dynamic var signature: String? = nil
    @objc dynamic var recipient: String = ""
    @objc dynamic var assetId: String? = nil
    @objc dynamic var feeAssetId: String? = nil
    @objc dynamic var feeAsset: String? = nil    
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var attachment: String? = nil
}
