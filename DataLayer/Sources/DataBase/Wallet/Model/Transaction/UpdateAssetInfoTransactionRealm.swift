//
//  IssueTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

final class UpdateAssetInfoTransactionRealm: TransactionRealm {
    
    @objc dynamic var assetId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var assetDescription: String = ""
    @objc dynamic var feeAssetId: String? = nil
}
