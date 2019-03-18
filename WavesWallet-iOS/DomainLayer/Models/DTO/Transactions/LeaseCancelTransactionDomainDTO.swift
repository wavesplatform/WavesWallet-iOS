//
//  TransactionLeaseCancelNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct LeaseCancelTransaction {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Date
        let version: Int
        let height: Int64
        
        let signature: String?
        let proofs: [String]?
        let chainId: Int?
        let leaseId: String
        var lease: DomainLayer.DTO.LeaseTransaction?
        var modified: Date
        var status: TransactionStatus
    }
}
