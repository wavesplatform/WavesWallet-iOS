//
//  TransactionsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension API.Service {

    struct Transactions {
        enum Kind {
            // TODO: Need response
            case getExchange(id: String)
            // TODO: Need response
            case getExchangeWithFilters(API.Query.ExchangeFilters)
        }

        let environment: Environment
        let kind: Kind
    }
}

extension API.Service.Transactions: ApiTargetType {

    fileprivate enum Constants {
        static let assets = "asset"
    }

    var path: String {
        switch kind {
        case .getExchange(let id):
            return Constants.assets + "/\(id)".urlEscaped

        case .getExchangeWithFilters:
            return Constants.assets
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getExchange, .getExchangeWithFilters:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getExchange:
            return .requestPlain

        case .getExchangeWithFilters(let filter):
            return .requestParameters(parameters: filter.dictionary, encoding: URLEncoding.default)
        }
    }
}
