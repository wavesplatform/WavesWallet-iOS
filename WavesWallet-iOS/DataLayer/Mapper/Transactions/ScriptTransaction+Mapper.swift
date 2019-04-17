//
//  ScriptTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension
import WavesSDKCrypto

extension ScriptTransaction {

    convenience init(transaction: DomainLayer.DTO.ScriptTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = 1
        height = transaction.height ?? -1
        chainId.value = transaction.chainId
        signature = transaction.signature
        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        script = transaction.script
        modified = transaction.modified
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.ScriptTransaction {

    init(transaction: Node.DTO.ScriptTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        chainId = transaction.chainId
        signature = transaction.signature
        proofs = transaction.proofs
        script = transaction.script
        modified = Date()
        self.status = status
    }

    init(transaction: ScriptTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        modified = transaction.modified
        height = transaction.height
        chainId = transaction.chainId.value
        signature = transaction.signature
        proofs = transaction.proofs.toArray()
        script = transaction.script
        version = transaction.version
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
