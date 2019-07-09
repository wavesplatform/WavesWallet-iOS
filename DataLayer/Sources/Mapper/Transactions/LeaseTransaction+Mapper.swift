//
//  LeasingTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDK
import DomainLayer

extension LeaseTransaction {

    convenience init(transaction: DomainLayer.DTO.LeaseTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        chainId.value = transaction.chainId
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

extension DomainLayer.DTO.LeaseTransaction {

    init(transaction: NodeService.DTO.LeaseTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {
        
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height ?? -1,
                  chainId: nil,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  amount: transaction.amount,
                  recipient: transaction.recipient.normalizeAddress(environment: environment),
                  modified: Date(),
                  status: status)
    }

    init(transaction: LeaseTransaction) {

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
                  amount: transaction.amount,
                  recipient: transaction.recipient,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)        
    }
}
