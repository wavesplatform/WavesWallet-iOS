//
//  ReissueTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer

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

    init(transaction: NodeService.DTO.ReissueTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {
        
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
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

    init(transaction: ReissueTransaction) {
        
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
                  quantity: transaction.quantity,
                  reissuable: transaction.reissuable,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
