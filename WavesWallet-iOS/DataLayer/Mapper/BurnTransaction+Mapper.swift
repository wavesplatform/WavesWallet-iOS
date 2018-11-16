//
//  BurnTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension BurnTransaction {

    convenience init(transaction: DomainLayer.DTO.BurnTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        assetId = transaction.assetId
        signature = transaction.signature
        chainId.value = transaction.chainId
        amount = transaction.amount
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.BurnTransaction {

    init(transaction: Node.DTO.BurnTransaction, status: DomainLayer.DTO.TransactionStatus) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = Date()

        assetId = transaction.assetId
        signature = transaction.signature
        chainId = transaction.chainId
        amount = transaction.amount
        proofs = transaction.proofs
        self.status = status
    }

    init(transaction: BurnTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        assetId = transaction.assetId        
        signature = transaction.signature
        chainId = transaction.chainId.value
        amount = transaction.amount
        proofs = []
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
