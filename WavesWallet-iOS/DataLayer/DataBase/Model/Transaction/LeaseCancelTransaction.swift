//
//  LeaseCancelTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class LeaseCancelTransaction: Transaction {
    @objc dynamic var signature: String? = nil
    var chainId: RealmOptional<Int> = RealmOptional<Int>()
    @objc dynamic var leaseId: String = ""
    @objc dynamic var lease: LeaseTransaction?
}
