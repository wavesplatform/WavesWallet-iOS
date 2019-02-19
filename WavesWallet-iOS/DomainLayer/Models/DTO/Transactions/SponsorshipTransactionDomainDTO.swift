//
//  SponsorshipTransaction.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct SponsorshipTransaction {

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let version: Int
        let height: Int64?

        let signature: String?
        let proofs: [String]?

        var assetId: String
        let minSponsoredAssetFee: Int64?

        var modified: Date
        var status: TransactionStatus
    }
}
