//
//  InvokeScriptTransaction.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/11/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class InvokeScriptTransactionPayment: Object {
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var assetId: String? = nil
}

final class InvokeScriptTransaction: Transaction {
    
    @objc dynamic var dappAddress: String = ""
    @objc dynamic var feeAssetId: String? = nil
    @objc dynamic var payment: InvokeScriptTransactionPayment?
}
