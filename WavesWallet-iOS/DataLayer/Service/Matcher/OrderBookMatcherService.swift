//
//  MatcherNodeService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension MoyaProvider {
    final class func matcherMoyaProvider<Target: TargetType>() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(callbackQueue: nil,
                                    plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    }
}

extension Matcher.Service {

    struct OrderBook {
        enum Kind {
           
            case getOrderHistory(TimestampSignature, isActiveOnly: Bool)
            case getOrderBook(amountAsset: String, priceAsset: String)
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
        
        case .getOrderBook(let amountAsset, let priceAsset):
            return Constants.matcher + "/" + Constants.orderbook + "/" + amountAsset + "/" + priceAsset
        }
    }

    var method: Moya.Method {
        switch kind {
        case .getOrderHistory:
            return .get
        
        case .getOrderBook:
            return .get
        }
    }

    var task: Task {
        switch kind {
        case .getOrderHistory(_, let isActiveOnly):

            return .requestCompositeParameters(bodyParameters: [:],
                                               bodyEncoding: URLEncoding.httpBody,
                                               urlParameters: [Constants.activeOnly: isActiveOnly])
        
        case .getOrderBook:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ContentType.applicationJson.headers

        switch kind {
        case .getOrderHistory(let signature, _):            
            headers.merge(signature.parameters) { a, _ in a }
            
        default:
            break
        }

        return headers
    }
}
