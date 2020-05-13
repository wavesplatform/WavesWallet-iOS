//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK
import WavesSDKExtensions

extension IssueTransactionRealm {
    convenience init(transaction: IssueTransaction) {
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

extension IssueTransaction {
    init(transaction: NodeService.DTO.IssueTransaction,
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
                  chainId: nil,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  assetId: transaction.assetId,
                  name: transaction.name,
                  quantity: transaction.quantity,
                  reissuable: transaction.reissuable,
                  decimals: transaction.decimals,
                  description: transaction.description,
                  script: transaction.script,
                  modified: Date(),
                  status: status)
    }

    init(transaction: IssueTransactionRealm) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  chainId: transaction.chainId.value,
                  signature: transaction.signature,
                  proofs: transaction.proofs.toArray(),
                  assetId: transaction.assetId,
                  name: transaction.name,
                  quantity: transaction.quantity,
                  reissuable: transaction.reissuable,
                  decimals: transaction.decimals,
                  description: transaction.assetDescription,
                  script: transaction.script,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
