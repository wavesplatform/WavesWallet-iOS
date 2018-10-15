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
    enum Transaction {
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
    }

    var path: String {
        switch self {
        case .list(let accountAddress, let limit):
            return Constants.transactions + "/" + Constants.address + "/" + "\(accountAddress)".urlEscaped + "/" + Constants.limit + "/" + "\(limit)".urlEscaped
            
        case .info(let id):
            return Constants.transactions + "/" + Constants.info + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .list, .info:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .list, .info:
            return .requestPlain
        }
    }
}
