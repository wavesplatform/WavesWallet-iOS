//
//  SetScriptTransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct ScriptTransaction {

        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let version: Int
        public let height: Int64?
        public let chainId: Int?

        public let signature: String?
        public let proofs: [String]?
        public var script: String?
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64?, chainId: Int?, signature: String?, proofs: [String]?, script: String?, modified: Date, status: TransactionStatus) {
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
            self.script = script
            self.modified = modified
            self.status = status
        }
    }
}
