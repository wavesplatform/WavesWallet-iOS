//
//  MatcherNodeService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import Moya

extension Matcher.Service {
    enum OrderBook {
        /**
         Response:
         - Node.Model.AccountBalance.self
         */
        case getOrderHistory(PublicKeyAccount)
    }
}

extension Matcher.Service.OrderBook: MatcherTargetType {
    private enum Constants {
        static let addresses = "addresses"
        static let balance = "balance"
    }

    var path: String {
        switch self {
        case .getOrderHistory(let id):
            return Constants.addresses + "/" + Constants.balance + "/" + "\(id)".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .getOrderHistory:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getOrderHistory:
            return .requestPlain
        }
    }
}
