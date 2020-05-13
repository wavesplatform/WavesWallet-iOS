//
//  ExchangeTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift

final class ExchangeTransactionRealm: TransactionRealm {

    @objc dynamic var amount: Int64 = 0
    @objc dynamic var price: Int64 = 0    
    @objc dynamic var buyMatcherFee: Int64 = 0
    @objc dynamic var sellMatcherFee: Int64 = 0
    @objc dynamic var order1: ExchangeTransactionOrderRealm?
    @objc dynamic var order2: ExchangeTransactionOrderRealm?
}

final class ExchangeTransactionOrderRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var sender: String = ""
    @objc dynamic var senderPublicKey: String = ""
    @objc dynamic var matcherPublicKey: String = ""
    @objc dynamic var assetPair: ExchangeTransactionAssetPairRealm?
    @objc dynamic var orderType: String = ""
    @objc dynamic var price: Int64 = 0
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var timestamp: Date = Date()
    @objc dynamic var expiration: Int64 = 0
    @objc dynamic var matcherFee: Int64 = 0
    @objc dynamic var signature: String? = nil
    @objc dynamic var matcherFeeAssetId: String? = nil
}

final class ExchangeTransactionAssetPairRealm: Object {
    @objc dynamic var amountAsset: String? = nil
    @objc dynamic var priceAsset: String? = nil
}
