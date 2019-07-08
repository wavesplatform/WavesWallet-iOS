//
//  TransactionDataNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {

    struct DataTransaction: Decodable {

        struct Data: Decodable {

            enum Value {
                case bool(Bool)
                case integer(Int)
                case string(String)
                case binary(String)
            }

            let key: String
            let type: String
            let value: Value
        }

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Date
        let height: Int64?
        let version: Int

        let proofs: [String]?
        let data: [Data]
     }
}

extension Node.DTO.DataTransaction.Data {

    enum CodingKeys: String, CodingKey {
        case key
        case type
        case value
    }

    enum ValueKey: String {
        case boolean
        case integer
        case string
        case binary
    }

    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKey: .key) {
            key = value
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Not found key"))
        }

        if let value = try container.decodeIfPresent(String.self, forKey: .type) {
            type = value
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Not found value"))
        }

        if let type = ValueKey(rawValue: self.type) {
            switch type {
            case .boolean:
                value = .bool(try container.decode(Bool.self, forKey: .value))
            case .integer:
                value = .integer(try container.decode(Int.self, forKey: .value))
            case .string:
                value = .string(try container.decode(String.self, forKey: .value))
            case .binary:
                value = .binary(try container.decode(String.self, forKey: .value))
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                         debugDescription: "Not found value"))
        }
    }
}
