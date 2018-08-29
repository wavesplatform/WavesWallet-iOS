//
//  TransactionBurnNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    struct TransactionBurnTransactionBurn: Decodable {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let signature: String
        let chainId: String?
        let version: Int
        let assetId: String
        let amount: Int64
        let height: Int64
    }
}
