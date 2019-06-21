//
//  BurnTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer

extension BurnTransaction {

    convenience init(transaction: DomainLayer.DTO.BurnTransaction) {
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

extension DomainLayer.DTO.BurnTransaction {

    init(transaction: NodeService.DTO.BurnTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
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
                  status: status)
    }

    init(transaction: BurnTransaction) {
        
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
                  chainId: transaction.chainId.value,
                  assetId: transaction.assetId,
                  amount: transaction.amount,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)        
    }
}
