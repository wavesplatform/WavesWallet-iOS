//
//  BasicTransaction.swift
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

public class BasicTransaction: Object, IdentifiableType {

    @objc dynamic var id: String = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var sender: String = ""    
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var fee: Int64 = 0
    @objc dynamic var height: Int64 = 0


    @available(*, deprecated, message: "need remove")
    @objc dynamic var assetId: String = ""
    @available(*, deprecated, message: "need remove")
    @objc dynamic var amount: Int64 = 0
    @available(*, deprecated, message: "need remove")
    @objc dynamic var isInput = false
    @available(*, deprecated, message: "need remove")
    @objc dynamic var counterParty = ""
    @available(*, deprecated, message: "need remove")
    @objc dynamic var isPending: Bool = false

    @available(*, deprecated, message: "need remove")
    @objc dynamic var asset: IssueTransaction?
    @available(*, deprecated, message: "need remove")
    @objc dynamic var addressBook: AddressBook?

    @available(*, deprecated, message: "need remove")
    convenience init(tx: Transaction) {
        self.init()
        id = tx.id
        type = tx.type
        sender = tx.sender
        timestamp = tx.timestamp
        fee = tx.fee
        assetId = tx.getAssetId()
        let realm = try! Realm()
        asset = realm.object(ofType: IssueTransaction.self, forPrimaryKey: assetId)
        amount = tx.getAmount()
        isInput = tx.isInput()
        counterParty = tx.getCounterParty()
        isPending = tx.isPending
    }

    @available(*, deprecated, message: "need remove")
    public var identity: String {
        return "\(id)"
    }

    override public static func primaryKey() -> String? {
        return "id"
    }
}

@available(*, deprecated, message: "need remove")
// equatable, this is needed to detect changes
func == (lhs: BasicTransaction, rhs: BasicTransaction) -> Bool {
    return lhs.id == rhs.id
}
