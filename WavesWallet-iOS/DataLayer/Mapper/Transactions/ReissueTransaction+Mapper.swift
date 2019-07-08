//
//  ReissueTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKCrypto

extension ReissueTransaction {

    convenience init(transaction: DomainLayer.DTO.ReissueTransaction) {
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
        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        signature = transaction.signature
        assetId = transaction.assetId
        chainId.value = transaction.chainId
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.ReissueTransaction {

    init(transaction: Node.DTO.ReissueTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {

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
        assetId = transaction.assetId
        chainId = transaction.chainId
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        proofs = transaction.proofs
        self.status = status
    }

    init(transaction: ReissueTransaction) {
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
        assetId = transaction.assetId
        chainId = transaction.chainId.value
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        proofs = transaction.proofs.toArray()
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
