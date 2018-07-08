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

    struct ExchangeFilters {
        // Address of a matcher which sent the transaction
        let matcher: String?
        // Address of a trader-participant in a transaction — an ORDER sender
        let sender: String?
        // Time range filter, start. Defaults to first transaction's time_stamp in db.
        let timeStart: String?
        // Time range filter, end. Defaults to now.
        let timeEnd: String?
        // Asset ID of the amount asset.
        let amountAsset: String?
        // Asset ID of the price asset.
        let priceAsset: String?
        // Cursor in base64 encoding. Holds information about timestamp, id, sort.
        let after: String?
        // Sort order. Gonna be rewritten by cursor's sort if present.
        let sort: String?
        // How many transactions to await in response.
        let limit: Int

        fileprivate var parameters: [String: Any] {
            var parameters = [String: Any]()

            if let matcher = matcher {
                parameters[Constants.matcher] = matcher
            }

            if let sender = sender {
                parameters[Constants.sender] = sender
            }

            if let timeStart = timeStart {
                parameters[Constants.timeStart] = timeStart
            }

            if let timeEnd = timeEnd {
                parameters[Constants.timeEnd] = timeEnd
            }

            if let amountAsset = amountAsset {
                parameters[Constants.amountAsset] = amountAsset
            }

            if let priceAsset = priceAsset {
                parameters[Constants.priceAsset] = priceAsset
            }

            if let after = after {
                parameters[Constants.after] = after
            }

            if let sort = sort {
                parameters[Constants.after] = sort
            }

            parameters[Constants.limit] = limit

            return parameters
        }
    }

    enum Transactions {
        case getExchange(id: String)
        case getExchangeWithFilters(ExchangeFilters)
    }
}

extension DataService.Transactions: ApiType {

    private enum Constants {
        static let assets = "asset"
    }

    var apiVersion: String {
        return "v0"
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
        case .getExchangeWithFilters(let filter)
            return .requestParameters(parameters: filter.parameters, encoding: URLEncoding.default)
        }
    }
}
