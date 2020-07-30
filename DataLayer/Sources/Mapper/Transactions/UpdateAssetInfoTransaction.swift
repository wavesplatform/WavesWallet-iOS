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

extension UpdateAssetInfoTransactionRealm {
    convenience init(transaction: UpdateAssetInfoTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        chainId.value = Int8(transaction.chainId ?? 0)
        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        assetId = transaction.assetId
        name = transaction.name
        assetDescription = transaction.description
        modified = transaction.modified
        status = transaction.status.rawValue
    }
}

extension UpdateAssetInfoTransaction {
    init(transaction: NodeService.DTO.UpdateAssetInfoTransaction,
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
                  height: transaction.height ?? 0,
                  chainId: nil,
                  feeAssetId: transaction.feeAssetId,
                  proofs: transaction.proofs,
                  assetId: transaction.assetId,
                  name: transaction.name,
                  description: transaction.description,
                  modified: Date(),
                  status: status ?? transactionStatus ?? .completed)
    }

    init(transaction: UpdateAssetInfoTransactionRealm) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  chainId: UInt8(transaction.chainId.value ?? 0),
                  feeAssetId: transaction.feeAssetId,
                  proofs: transaction.proofs.toArray(),
                  assetId: transaction.assetId,
                  name: transaction.name,
                  description: transaction.assetDescription,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
