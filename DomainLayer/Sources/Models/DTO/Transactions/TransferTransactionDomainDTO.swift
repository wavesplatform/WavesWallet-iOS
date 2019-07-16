//
//  TransactionTransferNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    struct TransferTransaction: Decodable, Mutating {
        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let version: Int
        public let height: Int64

        public let signature: String?
        public let proofs: [String]?
        public let recipient: String
        public var assetId: String
        public let feeAssetId: String
        public let feeAsset: String?
        public let amount: Int64
        public let attachment: String?
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64, signature: String?, proofs: [String]?, recipient: String, assetId: String, feeAssetId: String, feeAsset: String?, amount: Int64, attachment: String?, modified: Date, status: TransactionStatus) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.version = version
            self.height = height
            self.signature = signature
            self.proofs = proofs
            self.recipient = recipient
            self.assetId = assetId
            self.feeAssetId = feeAssetId
            self.feeAsset = feeAsset
            self.amount = amount
            self.attachment = attachment
            self.modified = modified
            self.status = status
        }
    }
}
