//
//  TransactionMassTransferNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    struct TransactionMassTransfer {

        struct Transfer {
            let recipient: String
            let amount: Int
        }

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let proofs: [String]
        let version: Int
        let assetId: String
        let attachment: String
        let transferCount: Int
        let totalAmount: Int64
        let transfers: [Transfer]
        let height: Int64
    }
}
