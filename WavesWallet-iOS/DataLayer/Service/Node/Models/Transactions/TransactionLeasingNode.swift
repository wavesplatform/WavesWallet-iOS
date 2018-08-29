//
//  TransactionLeasingNode.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    struct LeasingTransaction: Decodable {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let signature: String
        let version: Int
        let amount: Int64
        let recipient: String
        let height: Int64
    }
}
