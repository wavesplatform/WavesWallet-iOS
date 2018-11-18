//
//  LeaseCancelTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension LeaseCancelTransaction {

    convenience init(transaction: DomainLayer.DTO.LeaseCancelTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        signature = transaction.signature
        chainId.value = transaction.chainId
        leaseId = transaction.leaseId
        if let lease = transaction.lease {
            if let leaseFromBD = self.realm?.object(ofType: LeaseTransaction.self, forPrimaryKey: leaseId) {
                self.lease = leaseFromBD
            } else {
                self.lease = LeaseTransaction(transaction: lease)
            }
        }
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.LeaseCancelTransaction {

    init(transaction: Node.DTO.LeaseCancelTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = Date()

        signature = transaction.signature
        chainId = transaction.chainId
        leaseId = transaction.leaseId
        lease = DomainLayer.DTO.LeaseTransaction(transaction: transaction.lease, status: .completed, environment: environment)
        proofs = transaction.proofs
        self.status = status
    }

    init(transaction: LeaseCancelTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        signature = transaction.signature
        chainId = transaction.chainId.value
        leaseId = transaction.leaseId
        if let lease = transaction.lease {
            self.lease = DomainLayer.DTO.LeaseTransaction(transaction: lease)
        } else {
            self.lease = nil
        }
        proofs = []
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
