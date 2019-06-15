//
//  SponsorshipTransaction.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    public struct SponsorshipTransaction {

        public let type: Int
        public let id: String
        public let sender: String
        public let senderPublicKey: String
        public let fee: Int64
        public let timestamp: Date
        public let version: Int
        public let height: Int64?

        public let signature: String?
        public let proofs: [String]?

        public var assetId: String
        public let minSponsoredAssetFee: Int64?

        public var modified: Date
        public var status: TransactionStatus

        public init(type: Int, id: String, sender: String, senderPublicKey: String, fee: Int64, timestamp: Date, version: Int, height: Int64?, signature: String?, proofs: [String]?, assetId: String, minSponsoredAssetFee: Int64?, modified: Date, status: TransactionStatus) {
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
            self.assetId = assetId
            self.minSponsoredAssetFee = minSponsoredAssetFee
            self.modified = modified
            self.status = status
        }
    }
}
