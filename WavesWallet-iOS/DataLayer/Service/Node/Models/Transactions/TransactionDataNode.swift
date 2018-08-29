//
//  TransactionDataNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {

    struct TransactionData: Decodable {

        struct Data: Decodable {
            let key: String
            let type: String
            let value: Value
        }

        enum Value: Decodable {
            case bool(Bool)
            case integer(Int)
            case string(String)
            case binary(String)
        }

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int
        let timestamp: Int
        let proofs: [String]
        let version: Int
        let data: [Data]
        let height: Int
    }
}

extension Node.DTO.TransactionData.Value {

    enum CodingKeys: String, CodingKey {
        case bool
        case integer
        case string
        case binary
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(Bool.self, forKey: .bool) {
            self = .bool(value)
        } else if let value = try container.decodeIfPresent(Int.self, forKey: .integer) {
            self = .integer(value)
        } else if let value = try container.decodeIfPresent(String.self, forKey: .string) {
            self = .string(value)
        } else if let value = try container.decodeIfPresent(String.self, forKey: .binary) {
            self = .binary(value)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: container.codingPath,
                                                                       debugDescription: "Incorrect Value"))
        }
    }
}

