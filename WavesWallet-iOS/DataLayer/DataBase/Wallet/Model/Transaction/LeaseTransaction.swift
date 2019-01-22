//
//  LeasingTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class LeaseTransaction: Transaction {    
    @objc dynamic var amount: Int64 = 0
    @objc dynamic var recipient: String = ""
}
