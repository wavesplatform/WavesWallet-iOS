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
        case getReservedBalances(PrivateKeyAccount)
    }
}

extension Matcher.Service.Balance: MatcherTargetType {
    private enum Constants {
        static let matcher = "matcher"
        static let balance = "balance"
        static let timestamp = "timestamp"
    }

    var path: String {
        switch self {
        case .getReservedBalances(let privateKey):
            return Constants.matcher
                + "/"
                + Constants.balance
                + "/"
                + "\(privateKey.getPublicKeyStr())".urlEscaped
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
        case .getReservedBalances(let privateKey):
            let signature = TimestampSignature(privateKey: privateKey)
            headers.merge(signature.parameters) { a, _ in a }
        }

        return headers
    }
}
