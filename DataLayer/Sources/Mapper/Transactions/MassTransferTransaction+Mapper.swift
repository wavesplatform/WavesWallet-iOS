//
//  MassTransferTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDK
import DomainLayer

extension MassTransferTransaction {

    convenience init(transaction: DomainLayer.DTO.MassTransferTransaction) {
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
            .map { model -> MassTransferTransactionTransfer in
                let info = MassTransferTransactionTransfer()
                info.recipient = model.recipient
                info.amount = model.amount
                return info
            }

        self.transfers.append(objectsIn: transfers)

        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.MassTransferTransaction {

    init(transaction: NodeService.DTO.MassTransferTransaction,
         status: DomainLayer.DTO.TransactionStatus,
         environment: WalletEnvironment) {

        let transfers: [DomainLayer.DTO.MassTransferTransaction.Transfer] = transaction
            .transfers
            .map { .init(recipient: $0.recipient.normalizeAddress(environment: environment),
                         amount: $0.amount) }

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
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

    init(transaction: MassTransferTransaction) {

        let transfers = transaction
            .transfers
            .toArray()
            .map { DomainLayer.DTO.MassTransferTransaction.Transfer(recipient: $0.recipient,
                                                                    amount: $0.amount) }
        
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
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
