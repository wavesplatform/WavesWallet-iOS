//
//  DataTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

import Foundation
import RealmSwift

final class DataTransactionRealm: TransactionRealm {

    @objc dynamic var amount: Int64 = 0
    @objc dynamic var price: Int64 = 0        
    let data: List<DataTransactionDataRealm> = .init()
}

final class DataTransactionDataRealm: Object {
    @objc dynamic var key: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var string: String? = nil
    @objc dynamic var binary: String? = nil
    var boolean: RealmOptional<Bool> = .init()
    var integer: RealmOptional<Int> = .init()
}
