//
//  InvokeScriptTransactionNode.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/9/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    
    struct InvokeScriptTransaction: Decodable {
        
        struct Call: Decodable {
            
            struct Args: Decodable {
                enum Value {
                    case bool(Bool)
                    case integer(Int)
                    case string(String)
                    case binary(String)
                }
                
                let type: String
                let value: Value
            }
            
            let function: String
            let args: [Args]
        }
        
        struct Payment: Decodable {
            let amount: Int64
            let assetId: String?
        }
        
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let feeAssetId: String?
        let timestamp: Date
        let proofs: [String]?
        let version: Int
        let dApp: String
        let call: Call?
        let payment: [Payment]
        let height: Int64
    }
}


extension Node.DTO.InvokeScriptTransaction.Call.Args {
    
    enum CodingKeys: String, CodingKey {
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
        
        if let value = try container.decodeIfPresent(String.self, forKey: .type) {
            type = value
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath,
                                                                    debugDescription: "Not found type"))
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
