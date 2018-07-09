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
    enum Transactions {
        // TODO: Need response
        case getExchange(id: String)
        // TODO: Need response
        case getExchangeWithFilters(API.Query.ExchangeFilters)
    }
}

extension API.Service.Transactions: ApiTargetType {

    private enum Constants {
        static let assets = "asset"
    }

    var path: String {
        switch self {
        case .getExchange(let id):
            return Constants.assets + "/\(id)".urlEscaped

        case .getExchangeWithFilters:
            return Constants.assets
        }
    }

    var method: Moya.Method {
        switch self {
        case .getExchange, .getExchangeWithFilters:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getExchange:
            return .requestPlain

        case .getExchangeWithFilters(let filter):
            return .requestParameters(parameters: filter.dictionary, encoding: URLEncoding.default)
        }
    }
}
