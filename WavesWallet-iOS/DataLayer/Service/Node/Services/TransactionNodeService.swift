//
//  TransactionsService.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension Node.Service {

    struct Transaction {
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

            case broadcast([String: Any])
        }

        var kind: Kind
        var environment: Environment
    }
}

extension Node.Service.Transaction: NodeTargetType {
    var modelType: Encodable.Type {
        return String.self
    }

    fileprivate enum Constants {
        static let transactions = "transactions"
        static let limit = "limit"
        static let address = "address"
        static let info = "info"
        static let broadcast = "broadcast"
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
            
        case .broadcast(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
}
