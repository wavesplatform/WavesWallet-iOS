//
//  UnrecognisedTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.08.2018.1
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Transaction {

    convenience init(transaction: DomainLayer.DTO.UnrecognisedTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = 1
        height = transaction.height
        modified = transaction.modified
    }
}

extension DomainLayer.DTO.UnrecognisedTransaction {

    init(transaction: Node.DTO.UnrecognisedTransaction) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        modified = Date()
    }

    init(transaction: Transaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        modified = transaction.modified
        height = transaction.height
    }
}
