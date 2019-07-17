//
//  TransactionMassTransferNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    struct MassTransferTransaction: Mutating {

       public struct Transfer {
            public let recipient: String
            public let amount: Int64

            public init(recipient: String, amount: Int64) {
                self.recipient = recipient
                self.amount = amount
            }
        }

        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let version: Int
        public let height: Int64

        public let proofs: [String]?
        public var assetId: String
        public let attachment: String
        public let transferCount: Int
        public let totalAmount: Int64
        public let transfers: [Transfer]
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64, proofs: [String]?, assetId: String, attachment: String, transferCount: Int, totalAmount: Int64, transfers: [Transfer], modified: Date, status: TransactionStatus) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.version = version
            self.height = height
            self.proofs = proofs
            self.assetId = assetId
            self.attachment = attachment
            self.transferCount = transferCount
            self.totalAmount = totalAmount
            self.transfers = transfers
            self.modified = modified
            self.status = status
        }
    }
}
