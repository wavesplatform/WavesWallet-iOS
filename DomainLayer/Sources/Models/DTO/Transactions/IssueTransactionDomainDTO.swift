//
//  TransactionIssueNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct IssueTransaction {
        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let version: Int
        public let height: Int64

        public let chainId: Int?
        public let signature: String?
        public let proofs: [String]?
        public let assetId: String
        public let name: String
        public let quantity: Int64
        public let reissuable: Bool
        public let decimals: Int
        public let description: String
        public let script: String?
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64, chainId: Int?, signature: String?, proofs: [String]?, assetId: String, name: String, quantity: Int64, reissuable: Bool, decimals: Int, description: String, script: String?, modified: Date, status: TransactionStatus) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.version = version
            self.height = height
            self.chainId = chainId
            self.signature = signature
            self.proofs = proofs
            self.assetId = assetId
            self.name = name
            self.quantity = quantity
            self.reissuable = reissuable
            self.decimals = decimals
            self.description = description
            self.script = script
            self.modified = modified
            self.status = status
        }
    }
}
