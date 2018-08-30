//
//  TransactionDataNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct DataTransaction {
        struct Data {
            enum Value {
                case bool(Bool)
                case integer(Int)
                case string(String)
                case binary(String)
            }
            let key: String
            let value: Value
        }

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int
        let timestamp: Int
        let height: Int
        let version: Int

        let proofs: [String]
        let data: [Data]
        var modified: Date
    }
}
