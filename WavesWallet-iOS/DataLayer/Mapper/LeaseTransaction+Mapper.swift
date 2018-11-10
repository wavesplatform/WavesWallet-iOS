//
//  LeasingTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension LeaseTransaction {

    convenience init(transaction: DomainLayer.DTO.LeaseTransaction) {
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

extension DomainLayer.DTO.LeaseTransaction {

    init(transaction: Node.DTO.LeaseTransaction) {
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
        height = transaction.height ?? -1
        modified = Date()
        proofs = transaction.proofs
    }

    init(transaction: LeaseTransaction) {
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
        proofs = []
    }
}
