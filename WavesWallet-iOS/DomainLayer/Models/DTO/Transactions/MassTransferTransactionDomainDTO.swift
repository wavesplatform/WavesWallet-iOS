//
//  TransactionMassTransferNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct MassTransferTransaction: Mutating {

        struct Transfer {
            let recipient: String
            let amount: Int64
        }

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Date
        let version: Int
        let height: Int64

        let proofs: [String]?
        var assetId: String        
        let attachment: String
        let transferCount: Int
        let totalAmount: Int64
        let transfers: [Transfer]
        var modified: Date
        var status: TransactionStatus
    }
}
