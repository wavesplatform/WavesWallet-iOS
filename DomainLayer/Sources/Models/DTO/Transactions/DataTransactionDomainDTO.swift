//
//  TransactionDataNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {

    struct DataTransaction {
        public struct Data {
            public enum Value {
                case bool(Bool)
                case integer(Int)
                case string(String)
                case binary(String)
            }
            public let key: String
            public let value: Value
            public let type: String

            public init(key: String, value: Value, type: String) {
                self.key = key
                self.value = value
                self.type = type
            }
        }

        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let height: Int64?
        public let version: Int

        public let proofs: [String]?
        public let data: [Data]
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, height: Int64?, version: Int, proofs: [String]?, data: [Data], modified: Date, status: TransactionStatus) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.height = height
            self.version = version
            self.proofs = proofs
            self.data = data
            self.modified = modified
            self.status = status
        }
    }
}
