//
//  BalanceMatcherService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import Foundation
import Moya

extension Matcher.Service {
    enum Balance {
        /**
         Response:
         - [AssetId: Balance] as [String: Int64]
         */
        case getReservedBalances(TimestampSignature)
    }
}

extension Matcher.Service.Balance: MatcherTargetType {
    fileprivate enum Constants {
        static let matcher = "matcher"
        static let balance = "balance"
        static let reserved = "reserved"
        static let timestamp = "timestamp"
    }

    var path: String {
        switch self {
        case .getReservedBalances(let signature):
            return Constants.matcher
                + "/"
                + Constants.balance
                + "/"
                + Constants.reserved
                + "/"
                + "\(signature.publicKey.getPublicKeyStr())".urlEscaped
        }
    }

    var method: Moya.Method {
        switch self {
        case .getReservedBalances:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getReservedBalances:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ContentType.applicationJson.headers

        switch self {
        case .getReservedBalances(let signature):            
            headers.merge(signature.parameters) { a, _ in a }
        }

        return headers
    }
}
