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

    struct OrderBook {
        enum Kind {
            /**
             Response:
             - Not implementation
             */
            case getOrderHistory(TimestampSignature, isActiveOnly: Bool)
        }

        var kind: Kind
        var environment: Environment
    }
}

extension Matcher.Service.OrderBook: MatcherTargetType {
    fileprivate enum Constants {
        static let matcher = "matcher"
        static let orderbook = "orderbook"
        static let activeOnly = "activeOnly"
    }

    var path: String {
        switch kind {
        case .getOrderHistory(let signature, _):
            return Constants.matcher
                + "/"
                + Constants.orderbook
                + "/"
                + "\(signature.publicKey.getPublicKeyStr())".urlEscaped
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getOrderHistory:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getOrderHistory(_, let isActiveOnly):

            return .requestCompositeParameters(bodyParameters: [:],
                                               bodyEncoding: URLEncoding.httpBody,
                                               urlParameters: [Constants.activeOnly: isActiveOnly])
        }
    }

    var headers: [String: String]? {
        var headers = ContentType.applicationJson.headers

        switch kind {
        case .getOrderHistory(let signature, _):            
            headers.merge(signature.parameters) { a, _ in a }
        }

        return headers
    }
}
