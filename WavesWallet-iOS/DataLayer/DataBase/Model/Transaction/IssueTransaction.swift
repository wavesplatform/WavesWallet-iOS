//
//  IssueTransaction.swift
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

final class IssueTransaction: Transaction {

    @objc dynamic var signature: String = ""
    @objc dynamic var assetId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var quantity: Int64 = 0
    @objc dynamic var reissuable: Bool = false
    @objc dynamic var decimals: Int = 0
    @objc dynamic var assetDescription: String = ""
    @objc dynamic var script: String? = nil

    @available(*, deprecated, message: "need remove")
    public required init?(json: JSON) {
        guard let name: String = "name" <~~ json
            , let quantity: Int64 = "quantity" <~~ json
            , let decimals: Int = "decimals" <~~ json
            , let reissuable: Bool = "reissuable" <~~ json else {
                return nil
        }

        self.name = name
        self.assetDescription = ("description" <~~ json) ?? ""
        self.quantity = quantity
        self.decimals = decimals
        self.reissuable = reissuable

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
    @available(*, deprecated, message: "need remove")
    public override func getAssetId() -> String {
        return id
    }

    @available(*, deprecated, message: "need remove")
    public override func getAmount() -> Int64 {
        return quantity
    }
}
