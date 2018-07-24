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
    @objc dynamic var id = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var sender = ""
    @objc dynamic var timestamp: Int64 = 0
    @objc dynamic var fee: Int64 = 0
    @objc dynamic var assetId: String = ""
    @objc dynamic var asset: IssueTransaction?
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var isInput = false
    @objc dynamic var addressBook: AddressBook?
    @objc dynamic var counterParty = ""
    @objc dynamic var isPending: Bool = false

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

    public var identity: String {
        return "\(id)"
    }

    override public static func primaryKey() -> String? {
        return "id"
    }
}
// equatable, this is needed to detect changes
func == (lhs: BasicTransaction, rhs: BasicTransaction) -> Bool {
    return lhs.id == rhs.id
}
