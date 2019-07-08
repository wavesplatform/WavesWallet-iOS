//
//  TransactionsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDKCrypto

extension API.Service {

    struct Transactions {
        enum Kind {

            /**
             Response:
             - API.Response<[API.Response<API.DTO.ExchangeTransaction]>.self
             */
            case getExchange(id: String)
            case getExchangeWithFilters(API.Query.ExchangeFilters)
        }

        let kind: Kind
        let environment: Environment
    }
}

extension API.Service.Transactions: ApiTargetType {

    private enum Constants {
        static let exchange = "transactions/exchange"
    }

    var path: String {
        switch kind {
        case .getExchange(let id):
            return Constants.exchange + "/\(id)".urlEscaped

        case .getExchangeWithFilters:
            return Constants.exchange
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
