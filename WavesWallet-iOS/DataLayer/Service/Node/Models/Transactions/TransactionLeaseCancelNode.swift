//
//  TransactionLeaseCancelNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    struct TransactionLeaseCancel: Decodable {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let signature: String
        let chainId: String?
        let version: Int
        let leaseId: String
        let lease: Node.DTO.LeasingTransaction
        let height: Int64
    }
}
