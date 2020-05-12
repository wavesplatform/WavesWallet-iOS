//
//  LeasingTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RealmSwift

final class LeaseTransactionRealm: TransactionRealm {    
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var recipient: String = ""
}
