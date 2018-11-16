//
//  TransferTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension TransferTransaction {

    convenience init(transaction: DomainLayer.DTO.TransferTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        assetId = transaction.assetId
        modified = transaction.modified

        recipient = transaction.recipient
        feeAssetId = transaction.feeAssetId
        feeAsset = transaction.feeAsset
        amount = transaction.amount
        attachment = transaction.attachment
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.TransferTransaction {

    init(transaction: Node.DTO.TransferTransaction, status: DomainLayer.DTO.TransactionStatus) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        assetId = transaction.assetId.normalizeAssetId
        modified = Date()

        recipient = transaction.recipient
        feeAssetId = transaction.feeAssetId.normalizeAssetId
        feeAsset = transaction.feeAsset
        amount = transaction.amount
        attachment = transaction.attachment
        proofs = transaction.proofs
        self.status = status
    }

    init(transaction: TransferTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        signature = transaction.signature
        assetId = transaction.assetId.normalizeAssetId
        modified = transaction.modified

        recipient = transaction.recipient
        feeAssetId = transaction.feeAssetId.normalizeAssetId
        feeAsset = transaction.feeAsset
        amount = transaction.amount
        attachment = transaction.attachment
        proofs = []
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}
