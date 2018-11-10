//
//  TransactionReissueNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct ReissueTransaction {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let version: Int
        let height: Int64

        let signature: String?
        let proofs: [String]?
        let chainId: Int?
        let assetId: String
        let quantity: Int64
        let reissuable: Bool
        var modified: Date
    }
}
