//
//  TransferTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDK
import DomainLayer
import Extensions

extension TransferTransaction {

    convenience init(transaction: DomainLayer.DTO.TransferTransaction) {
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
        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
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

     init(transaction: NodeService.DTO.TransferTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {

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
                  recipient: transaction.recipient.normalizeAddress(environment: environment),
                  assetId: transaction.assetId.normalizeAssetId,
                  feeAssetId: transaction.feeAssetId.normalizeAssetId,
                  feeAsset: transaction.feeAssetId,
                  amount: transaction.amount,
                  attachment: transaction.attachment,
                  modified: Date(),
                  status: status)
    }

    init(transaction: TransferTransaction) {
        
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
                  recipient: transaction.recipient,
                  assetId: transaction.assetId.normalizeAssetId,
                  feeAssetId: transaction.feeAssetId.normalizeAssetId,
                  feeAsset: transaction.feeAsset.normalizeAssetId,
                  amount: transaction.amount,
                  attachment: transaction.attachment,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
