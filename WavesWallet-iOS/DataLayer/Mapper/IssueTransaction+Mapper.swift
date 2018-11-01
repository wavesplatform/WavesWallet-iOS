//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension IssueTransaction {

    convenience init(transaction: DomainLayer.DTO.IssueTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        assetId = transaction.assetId
        name = transaction.name
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        decimals = transaction.decimals
        assetDescription = transaction.description
        script = transaction.script
        modified = transaction.modified
    }
}

extension DomainLayer.DTO.IssueTransaction {

    init(transaction: Node.DTO.IssueTransaction) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        assetId = transaction.assetId
        name = transaction.name
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        decimals = transaction.decimals
        description = transaction.description
        script = transaction.script
        modified = Date()
        proofs = transaction.proofs
    }

    init(transaction: IssueTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        assetId = transaction.assetId
        name = transaction.name
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        decimals = transaction.decimals
        description = transaction.assetDescription
        script = transaction.script
        modified = transaction.modified
        proofs = []
    }
}
