//
//  TransactionsService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension DataService {
    private enum Constants {
        static let matcher = "matcher"
        static let sender = "sender"
        static let timeStart = "timeStart"
        static let timeEnd = "timeEnd"
        static let amountAsset = "amountAsset"
        static let priceAsset = "priceAsset"
        static let after = "after"
        static let sort = "sort"
        static let limit = "limit"
    }

    enum Transactions {
        case getExchange(id: String)
        case getExchangeWithFilters(Query.ExchangeFilters)
    }
}

extension DataService.Transactions: DataTargetType {
    private enum Constants {
        static let assets = "asset"
    }

    var apiVersion: String {
        return "/v0"
    }

    var apiUrl: String {
        return Environments.current.servers.dataUrl.relativeString
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
