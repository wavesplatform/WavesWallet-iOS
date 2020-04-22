//
//  AliasTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

extension AliasTransaction {
    convenience init(transaction: DomainLayer.DTO.AliasTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height ?? -1
        modified = transaction.modified
        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        signature = transaction.signature
        alias = transaction.alias
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.AliasTransaction {
    init(transaction: NodeService.DTO.AliasTransaction,
         status: DomainLayer.DTO.TransactionStatus,
         environment: WalletEnvironment) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: environment.aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  alias: transaction.alias,
                  modified: Date(),
                  status: status)
    }

    init(transaction: AliasTransaction) {
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
                  alias: transaction.alias,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
