//
//  ReissueTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

extension ReissueTransactionRealm {
    convenience init(transaction: ReissueTransaction) {
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
        chainId.value = Int8(transaction.chainId ?? 0)
        quantity = transaction.quantity
        reissuable = transaction.reissuable
        status = transaction.status.rawValue
    }
}

extension ReissueTransaction {
    init(transaction: NodeService.DTO.ReissueTransaction,
         status: TransactionStatus,
         aliasScheme: String) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height ?? 0,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  chainId: transaction.chainId,
                  assetId: transaction.assetId,
                  quantity: transaction.quantity,
                  reissuable: transaction.reissuable,
                  modified: Date(),
                  status: status)
    }

    init(transaction: ReissueTransactionRealm) {
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
                  quantity: transaction.quantity,
                  reissuable: transaction.reissuable,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
