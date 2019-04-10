//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension
import WavesSDKCrypto

extension IssueTransaction {

    convenience init(transaction: DomainLayer.DTO.IssueTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        chainId.value = transaction.chainId
        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        assetId = transaction.assetId
        name = transaction.name
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        decimals = transaction.decimals
        assetDescription = transaction.description
        script = transaction.script
        modified = transaction.modified
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.IssueTransaction {

    init(transaction: Node.DTO.IssueTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        assetId = transaction.assetId
        name = transaction.name
        chainId = nil

        quantity = transaction.quantity
        reissuable = transaction.reissuable
        decimals = transaction.decimals
        description = transaction.description
        script = transaction.script
        modified = Date()
        proofs = transaction.proofs
        self.status = status
    }

    init(transaction: IssueTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
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
        proofs = transaction.proofs.toArray()
        chainId = transaction.chainId.value
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
