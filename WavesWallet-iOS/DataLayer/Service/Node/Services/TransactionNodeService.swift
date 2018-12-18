//
//  TransactionsService.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

fileprivate enum Constants {
    static let transactions = "transactions"
    static let limit = "limit"
    static let address = "address"
    static let info = "info"
    static let broadcast = "broadcast"

    static let version: String = "version"
    static let alias: String = "alias"
    static let fee: String = "fee"
    static let timestamp: String = "timestamp"
    static let type: String = "type"
    static let senderPublicKey: String = "senderPublicKey"
    static let proofs: String = "proofs"
    static let chainId: String = "chainId"
    static let recipient: String = "recipient"
    static let amount: String = "amount"
    static let quantity: String = "quantity"
    static let assetId: String = "assetId"
    static let leaseId: String = "leaseId"

}

extension Node.Service {

    struct Transaction {

        struct Burn {
            let version: Int
            let type: Int
            let scheme: String
            let fee: Int64
            let assetId: String
            let quantity: Int64
            let timestamp: Int64
            let senderPublicKey: String
            let proofs: [String]
        }
        
        struct Alias {
            let version: Int
            let name: String
            let fee: Int64
            let timestamp: Int64
            let type: Int
            let senderPublicKey: String
            let proofs: [String]?
        }

        struct Lease {
            let version: Int
            let scheme: String
            let fee: Int64
            let recipient: String
            let amount: Int64
            let timestamp: Int64
            let type: Int
            let senderPublicKey: String
            let proofs: [String]
        }

        struct LeaseCancel {
            let version: Int
            let scheme: String
            let fee: Int64
            let leaseId: String
            let timestamp: Int64
            let type: Int
            let senderPublicKey: String
            let proofs: [String]
        }

        enum BroadcastSpecification {
            case createAlias(Alias)
            case startLease(Lease)
            case cancelLease(LeaseCancel)
            case burn(Burn)
            
            var params: [String: Any] {
                switch self {
                case .burn(let burn):
                    return  [Constants.version: burn.version,
                             Constants.chainId: burn.scheme,
                             Constants.senderPublicKey: burn.senderPublicKey,
                             Constants.quantity: burn.quantity,
                             Constants.fee: burn.fee,
                             Constants.timestamp: burn.timestamp,
                             Constants.proofs: burn.proofs,
                             Constants.type: burn.type,
                             Constants.assetId: burn.assetId]
                    
                case .createAlias(let alias):
                    return [Constants.version: alias.version,
                            Constants.alias: alias.name,
                            Constants.fee: alias.fee,
                            Constants.timestamp: alias.timestamp,
                            Constants.type: alias.type,
                            Constants.senderPublicKey: alias.senderPublicKey,
                            Constants.proofs: alias.proofs ?? []]

                case .startLease(let lease):
                    let scheme: UInt8 = lease.scheme.utf8.last ?? UInt8(0)
                    return  [Constants.version: lease.version,
                             Constants.chainId: scheme,
                             Constants.senderPublicKey: lease.senderPublicKey,
                             Constants.recipient: lease.recipient,
                             Constants.amount: lease.amount,
                             Constants.fee: lease.fee,
                             Constants.timestamp: lease.timestamp,
                             Constants.proofs: lease.proofs,
                             Constants.type: lease.type]

                case .cancelLease(let lease):
                    let scheme: UInt8 = lease.scheme.utf8.last ?? UInt8(0)
                    return  [Constants.version: lease.version,
                             Constants.chainId: scheme,
                             Constants.senderPublicKey: lease.senderPublicKey,
                             Constants.fee: lease.fee,
                             Constants.timestamp: lease.timestamp,
                             Constants.proofs: lease.proofs,
                             Constants.type: lease.type,
                             Constants.leaseId: lease.leaseId]                
                }
            }
        }

        enum Kind {
            /**
             Response:
             - Node.DTO.TransactionContainers.self
             */
            case list(accountAddress: String, limit: Int)
            /**
             Response:
             - ?
             */
            case info(id: String)

            case broadcast(BroadcastSpecification)
        }

        var kind: Kind
        var environment: Environment
    }
}

extension Node.Service.Transaction: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    var path: String {
        switch kind {
        case .list(let accountAddress, let limit):
            return Constants.transactions + "/" + Constants.address + "/" + "\(accountAddress)".urlEscaped + "/" + Constants.limit + "/" + "\(limit)".urlEscaped
            
        case .info(let id):
            return Constants.transactions + "/" + Constants.info + "/" + "\(id)".urlEscaped

        case .broadcast:
            return Constants.transactions + "/" + Constants.broadcast
        }
    }

    var method: Moya.Method {
        switch kind {
        case .list, .info:
            return .get
        case .broadcast:
            return .post
        }
    }

    var task: Task {
        switch kind {
        case .list, .info:
            return .requestPlain
            
        case .broadcast(let specification):
            return .requestParameters(parameters: specification.params, encoding: JSONEncoding.default)
        }
    }
}
