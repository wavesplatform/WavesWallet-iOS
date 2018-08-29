//
//  LeasingTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension LeasingTransaction {
    //TODO: Remove
    convenience init(model: Node.DTO.TransactionLease) {
        self.init()
        type = model.type
        id = model.id
        sender = model.sender
        senderPublicKey = model.senderPublicKey
        fee = model.fee
        timestamp = model.timestamp
        signature = model.signature
        version = model.version
        amount = model.amount
        recipient = model.recipient
        height = model.height
        modified = Date()
    }

    convenience init(transaction: DomainLayer.DTO.LeasingTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        signature = transaction.signature
        version = transaction.version
        amount = transaction.amount
        recipient = transaction.recipient
        height = transaction.height
        modified = transaction.modified
    }
}

extension DomainLayer.DTO.LeasingTransaction {

    init(transaction: Node.DTO.TransactionLease) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        signature = transaction.signature
        version = transaction.version
        amount = transaction.amount
        recipient = transaction.recipient        
        height = transaction.height
        modified = Date()
    }

    init(transaction: LeasingTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        signature = transaction.signature
        version = transaction.version
        amount = transaction.amount
        recipient = transaction.recipient
        height = transaction.height        
        modified = transaction.modified
    }
}
