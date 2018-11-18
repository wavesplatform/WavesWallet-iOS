//
//  MassTransferTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

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
        proofs.append(objectsIn: transaction.proofs)

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

    init(transaction: Node.DTO.MassTransferTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = Date()

        assetId = transaction.assetId.normalizeAssetId
        attachment = transaction.attachment
        transferCount = transaction.transferCount
        totalAmount = transaction.totalAmount
        proofs = transaction.proofs

        transfers = transaction
            .transfers
            .map { .init(recipient: $0.recipient,
                         amount: $0.amount) }

        self.status = status
    }

    init(transaction: MassTransferTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        assetId = transaction.assetId.normalizeAssetId
        attachment = transaction.attachment
        transferCount = transaction.transferCount
        totalAmount = transaction.totalAmount
        proofs = transaction.proofs.toArray()

        transfers = transaction
            .transfers
            .map { .init(recipient: $0.recipient,
                         amount: $0.amount) }
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
