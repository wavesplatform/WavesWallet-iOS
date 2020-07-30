//
//  BurnTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

extension BurnTransactionRealm {
    convenience init(transaction: BurnTransaction) {
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

        assetId = transaction.assetId

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }

        amount = transaction.amount
        status = transaction.status.rawValue
    }
}

extension BurnTransaction {
    init(transaction: NodeService.DTO.BurnTransaction,
         status: TransactionStatus?,
         aliasScheme: String) {
        let transactionStatus = TransactionStatus.make(from: transaction.applicationStatus ?? "")

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height ?? -1,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  chainId: transaction.chainId,
                  assetId: transaction.assetId,
                  amount: transaction.amount,
                  modified: Date(),
                  status: status ?? transactionStatus ?? .completed)
    }

    init(transaction: BurnTransactionRealm) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  signature: transaction.signature,
                  proofs: transaction.proofs.toArray(),
                  chainId: UInt8(transaction.chainId.value ?? 0),
                  assetId: transaction.assetId,
                  amount: transaction.amount,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
