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

    @objc dynamic var signature: String = ""
    @objc dynamic var buyMatcherFee: Int64 = 0
    @objc dynamic var sellMatcherFee: Int64 = 0
    @objc dynamic var order1: ExchangeTransactionOrder?
    @objc dynamic var order2: ExchangeTransactionOrder?

    @available(*, deprecated, message: "need remove")
    @objc dynamic var sellSender = ""
    @available(*, deprecated, message: "need remove")
    @objc dynamic var buySender = ""
    @available(*, deprecated, message: "need remove")
    @objc dynamic var amountAsset = ""
    @available(*, deprecated, message: "need remove")
    @objc dynamic var priceAsset = ""

    @available(*, deprecated, message: "need remove")
    public required init?(json: JSON) {
        guard let sellSender: String = "order2.senderPublicKey" <~~ json
            , let buySender: String = "order1.senderPublicKey" <~~ json
            , let price: Int64 = "price" <~~ json
            , let amount: Int64 = "amount" <~~ json else {
                return nil
        }

        self.sellSender = sellSender
        self.buySender = buySender
        self.price = price
        self.amount = amount
        self.amountAsset = ("order1.assetPair.amountAsset" <~~ json) ?? ""
        self.priceAsset = ("order1.assetPair.priceAsset" <~~ json) ?? ""

        super.init(json: json)
    }

    required public init() {
        super.init()
    }

    /**
     WARNING: This is an internal initializer not intended for public use.
     :nodoc:
     */
    public required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    public required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    public override func getAssetId() -> String {
        return amountAsset
    }

    public override func getAmount() -> Int64 {
        return amount
    }

    public override func isInput() -> Bool {
        return buyerAddress == WalletManager.getAddress()
    }

    @available(*, deprecated, message: "need remove")
    var sellerAddress: String {
        return PublicKeyAccount(publicKey: Base58.decode(sellSender)).address
    }

    @available(*, deprecated, message: "need remove")
    var buyerAddress: String {
        return PublicKeyAccount(publicKey: Base58.decode(buySender)).address
    }

    @available(*, deprecated, message: "need remove")
    public override func isOur() -> Bool {
        return sellerAddress == WalletManager.getAddress() || buyerAddress == WalletManager.getAddress()
    }
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
    @objc dynamic var signature: String = ""
}

final class ExchangeTransactionAssetPair: Object {
    @objc dynamic var amountAsset: String? = nil
    @objc dynamic var priceAsset: String? = nil
}
