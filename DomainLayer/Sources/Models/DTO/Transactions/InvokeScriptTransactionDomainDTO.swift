//
//  InvokeScriptTransactionDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/9/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    
    struct InvokeScriptTransaction {
        
        public struct Payment {
            public let amount: Int64
            public let assetId: String?

            public init(amount: Int64, assetId: String?) {
                self.amount = amount
                self.assetId = assetId
            }
        }
        
        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let feeAssetId: String?
        public let timestamp: Date
        public let proofs: [String]?
        public let version: Int
        public let dappAddress: String
        public let payment: Payment?
        public let height: Int64
        
        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, feeAssetId: String?, timestamp: Date, proofs: [String]?, version: Int, dappAddress: String, payment: Payment?, height: Int64, modified: Date, status: TransactionStatus) {
            self.type = type
            self.id = id
            self.sender = sender
            self.senderPublicKey = senderPublicKey
            self.fee = fee
            self.feeAssetId = feeAssetId
            self.timestamp = timestamp
            self.proofs = proofs
            self.version = version
            self.dappAddress = dappAddress
            self.payment = payment
            self.height = height
            self.modified = modified
            self.status = status
        }
    }
}
