//
//  LeasingTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK
import WavesSDKExtensions

extension LeaseTransactionRealm {
    convenience init(transaction: LeaseTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        chainId.value = Int8(transaction.chainId ?? 0)
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

extension LeaseTransaction {
    init(transaction: NodeService.DTO.LeaseTransaction,
         status: TransactionStatus,
         aliasScheme: String) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height ?? -1,
                  chainId: nil,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  amount: transaction.amount,
                  recipient: transaction.recipient.normalizeAddress(aliasScheme: aliasScheme),
                  modified: Date(),
                  status: status)
    }

    init(transaction: LeaseTransactionRealm) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  chainId: UInt8(transaction.chainId.value ?? 0),
                  signature: transaction.signature,
                  proofs: transaction.proofs.toArray(),
                  amount: transaction.amount,
                  recipient: transaction.recipient,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
