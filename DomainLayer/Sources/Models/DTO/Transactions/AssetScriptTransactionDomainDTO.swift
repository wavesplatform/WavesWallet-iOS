//
//  AssetScriptTransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {

    struct AssetScriptTransaction {

        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let height: Int64
        public let signature: String?
        public let proofs: [String]?
        public let chainId: Int?
        public let version: Int
        public let script: String?
        public let assetId: String

        public let modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, height: Int64, signature: String?, proofs: [String]?, chainId: Int?, version: Int, script: String?, assetId: String, modified: Date, status: TransactionStatus) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.timestamp = timestamp
            self.height = height
            self.signature = signature
            self.proofs = proofs
            self.chainId = chainId
            self.version = version
            self.script = script
            self.assetId = assetId
            self.modified = modified
            self.status = status
        }
    }
}
