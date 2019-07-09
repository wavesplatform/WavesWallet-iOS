//
//  TransactionContainers.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDK
import DomainLayer

extension IssueTransaction {

    convenience init(transaction: DomainLayer.DTO.IssueTransaction) {
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

extension DomainLayer.DTO.IssueTransaction {

    init(transaction: NodeService.DTO.IssueTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
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

    init(transaction: IssueTransaction) {
        
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
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
