//
//  MassTransferTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK
import WavesSDKExtensions

extension MassTransferTransactionRealm {
    convenience init(transaction: MassTransferTransaction) {
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
        attachment = transaction.attachment
        transferCount = transaction.transferCount
        totalAmount = transaction.totalAmount

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        let transfers = transaction
            .transfers
            .map { model -> MassTransferTransactionTransferRealm in
                let info = MassTransferTransactionTransferRealm()
                info.recipient = model.recipient
                info.amount = model.amount
                return info
            }

        self.transfers.append(objectsIn: transfers)

        status = transaction.status.rawValue
    }
}

extension MassTransferTransaction {
    init(transaction: NodeService.DTO.MassTransferTransaction,
         status: TransactionStatus,
         aliasScheme: String) {
        
        let transfers: [MassTransferTransaction.Transfer] = transaction
            .transfers
            .map { .init(recipient: $0.recipient.normalizeAddress(aliasScheme: aliasScheme), amount: $0.amount) }

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height ?? 0,
                  proofs: transaction.proofs,
                  assetId: transaction.assetId.normalizeAssetId,
                  attachment: transaction.attachment,
                  transferCount: transaction.transferCount,
                  totalAmount: transaction.totalAmount,
                  transfers: transfers,
                  modified: Date(),
                  status: status)

        self.status = status
    }

    init(transaction: MassTransferTransactionRealm) {
        let transfers = transaction
            .transfers
            .toArray()
            .map { MassTransferTransaction.Transfer(recipient: $0.recipient, amount: $0.amount) }

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  proofs: transaction.proofs.toArray(),
                  assetId: transaction.assetId.normalizeAssetId,
                  attachment: transaction.attachment,
                  transferCount: transaction.transferCount,
                  totalAmount: transaction.totalAmount,
                  transfers: transfers,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
