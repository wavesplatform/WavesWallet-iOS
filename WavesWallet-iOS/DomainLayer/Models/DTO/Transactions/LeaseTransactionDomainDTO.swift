//
//  TransactionLeaseNode.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct LeaseTransaction {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Date
        let version: Int
        let height: Int64

        let chainId: Int?
        let signature: String?
        let proofs: [String]?
        let amount: Int64
        let recipient: String
        var modified: Date
        var status: TransactionStatus
    }
}
