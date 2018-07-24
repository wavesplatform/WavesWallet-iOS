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

public class ExchangeTransaction: Transaction {
    @objc dynamic var sellSender = ""
    @objc dynamic var buySender = ""
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var price: Int64 = 0
    @objc dynamic var amountAsset = ""
    @objc dynamic var priceAsset = ""


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

    var sellerAddress: String {
        return PublicKeyAccount(publicKey: Base58.decode(sellSender)).address
    }

    var buyerAddress: String {
        return PublicKeyAccount(publicKey: Base58.decode(buySender)).address
    }

    public override func isOur() -> Bool {
        return sellerAddress == WalletManager.getAddress() || buyerAddress == WalletManager.getAddress()
    }
}
