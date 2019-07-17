//
//  TransactionReissueNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct ReissueTransaction {
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
        public let chainId: Int?
        public let assetId: String
        public let quantity: Int64
        public let reissuable: Bool
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64, signature: String?, proofs: [String]?, chainId: Int?, assetId: String, quantity: Int64, reissuable: Bool, modified: Date, status: TransactionStatus) {
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
            self.chainId = chainId
            self.assetId = assetId
            self.quantity = quantity
            self.reissuable = reissuable
            self.modified = modified
            self.status = status
        }
    }
}
