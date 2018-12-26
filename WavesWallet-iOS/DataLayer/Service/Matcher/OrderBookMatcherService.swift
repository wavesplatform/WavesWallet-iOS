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
            
            case getOrderBook(amountAsset: String, priceAsset: String)
            case getMarket
            case getMyOrders(amountAsset: String, priceAsset: String, signature: TimestampSignature)
        }

        var kind: Kind
        var environment: Environment
    }
}

extension Matcher.Service.OrderBook: MatcherTargetType {
    fileprivate enum Constants {
        static let matcher = "matcher"
        static let orderbook = "orderbook"
        static let publicKey = "publicKey"
    }

    private var orderBookPath: String {
        return Constants.matcher + "/" + Constants.orderbook
    }
    
    var path: String {
        switch kind {
         
        case .getOrderBook(let amountAsset, let priceAsset):
            return orderBookPath + "/" + amountAsset + "/" + priceAsset
        
        case .getMarket:
            return orderBookPath
            
        case .getMyOrders(let amountAsset, let priceAsset, let signature):
            return orderBookPath + "/" + amountAsset + "/" + priceAsset + "/"
                + Constants.publicKey + "/" + signature.publicKey.getPublicKeyStr()
        }
    }

    var method: Moya.Method {
       return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        var headers = ContentType.applicationJson.headers

        switch kind {
        case .getMyOrders(_, _, let signature):
            headers.merge(signature.parameters) { a, _ in a }

        default:
            break
        }

        return headers
    }
}
