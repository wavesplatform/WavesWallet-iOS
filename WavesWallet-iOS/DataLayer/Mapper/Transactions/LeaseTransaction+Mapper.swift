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
        height = transaction.height
        chainId.value = transaction.chainId
        signature = transaction.signature
        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        amount = transaction.amount
        recipient = transaction.recipient
        modified = transaction.modified
        status = transaction.status.rawValue

    }
}

extension DomainLayer.DTO.LeaseTransaction {

    init(transaction: Node.DTO.LeaseTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        signature = transaction.signature
        version = transaction.version
        amount = transaction.amount
        recipient = transaction.recipient.normalizeAddress(environment: environment)

        height = transaction.height ?? -1
        chainId = nil
        modified = Date()
        proofs = transaction.proofs

        self.status = status
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
        chainId = transaction.chainId.value
        proofs = transaction.proofs.toArray()
        modified = transaction.modified
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
