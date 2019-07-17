//
//  TransactionLeaseNode.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct LeaseTransaction {
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
        public let amount: Int64
        public let recipient: String
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64, chainId: Int?, signature: String?, proofs: [String]?, amount: Int64, recipient: String, modified: Date, status: TransactionStatus) {
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
            self.amount = amount
            self.recipient = recipient
            self.modified = modified
            self.status = status
        }
    }
}
