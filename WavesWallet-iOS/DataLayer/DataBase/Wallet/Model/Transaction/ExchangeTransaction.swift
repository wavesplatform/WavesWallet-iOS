//
//  ExchangeTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Gloss
import RealmSwift
import Realm
import RxDataSources

final class ExchangeTransaction: Transaction {

    @objc dynamic var amount: Int64 = 0
    @objc dynamic var price: Int64 = 0
    @objc dynamic var signature: String? = nil
    @objc dynamic var buyMatcherFee: Int64 = 0
    @objc dynamic var sellMatcherFee: Int64 = 0
    @objc dynamic var order1: ExchangeTransactionOrder?
    @objc dynamic var order2: ExchangeTransactionOrder?
}

final class ExchangeTransactionOrder: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var sender: String = ""
    @objc dynamic var senderPublicKey: String = ""
    @objc dynamic var matcherPublicKey: String = ""
    @objc dynamic var assetPair: ExchangeTransactionAssetPair?
    @objc dynamic var orderType: String = ""
    @objc dynamic var price: Int64 = 0
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var expiration: Int64 = 0
    @objc dynamic var matcherFee: Int64 = 0
    @objc dynamic var signature: String? = nil
}

final class ExchangeTransactionAssetPair: Object {
    @objc dynamic var amountAsset: String? = nil
    @objc dynamic var priceAsset: String? = nil
}
