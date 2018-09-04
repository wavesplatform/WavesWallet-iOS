//
//  MassTransferTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RealmSwift

final class MassTransferTransaction: Transaction {

    @objc dynamic var assetId: String? = ""
    @objc dynamic var attachment: String = ""
    @objc dynamic var transferCount: Int = 0
    @objc dynamic var totalAmount: Int64 = 0
    let proofs: List<String> = .init()
    let transfers: List<MassTransferTransactionTransfer> = .init()
}

final class MassTransferTransactionTransfer: Object {
    @objc dynamic var recipient: String = ""
    @objc dynamic var amount: Int = 0    
}
