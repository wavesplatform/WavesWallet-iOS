//
//  UnrecognisedTransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct UnrecognisedTransaction {
        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let height: Int64
        public let modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, height: Int64, modified: Date, status: TransactionStatus) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.height = height
            self.modified = modified
            self.status = status
        }
    }
}
