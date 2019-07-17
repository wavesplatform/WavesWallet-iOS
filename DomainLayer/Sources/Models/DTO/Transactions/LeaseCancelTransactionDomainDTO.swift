//
//  TransactionLeaseCancelNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct LeaseCancelTransaction {
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
        public let leaseId: String
        public var lease: DomainLayer.DTO.LeaseTransaction?
        public var modified: Date
        public var status: TransactionStatus
    
        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64, signature: String?, proofs: [String]?, chainId: Int?, leaseId: String, lease: DomainLayer.DTO.LeaseTransaction?, modified: Date, status: TransactionStatus) {
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
            self.leaseId = leaseId
            self.lease = lease
            self.modified = modified
            self.status = status
        }
    }
}
