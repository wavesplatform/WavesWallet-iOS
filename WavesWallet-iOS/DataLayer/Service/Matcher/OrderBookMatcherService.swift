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
         - Not implementation
         */
        case getOrderHistory(PrivateKeyAccount, isActiveOnly: Bool)
    }
}
extension Matcher.Service.OrderBook: MatcherTargetType {
    private enum Constants {
        static let matcher = "matcher"
        static let orderbook = "orderbook"
        static let activeOnly = "activeOnly"
    }

    var path: String {
        switch self {
        case .getOrderHistory(let privateKey, _):
            return Constants.matcher
                + "/"
                + Constants.orderbook
                + "/"
                + "\(privateKey.getPublicKeyStr())".urlEscaped
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
        case .getOrderHistory(_, let isActiveOnly):

            return .requestCompositeParameters(bodyParameters: [:],
                                               bodyEncoding: URLEncoding.httpBody,
                                               urlParameters: [Constants.activeOnly: isActiveOnly])
        }
    }

    var headers: [String: String]? {
        var headers = ContentType.applicationJson.headers

        switch self {
        case .getOrderHistory(let privateKey, _):
            let signature = TimestampSignature(privateKey: privateKey)
            headers.merge(signature.parameters) { a, _ in a }
        }

        return headers
    }
}
