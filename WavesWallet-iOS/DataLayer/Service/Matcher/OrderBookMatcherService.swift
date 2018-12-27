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
            case cancelOrder(Matcher.Query.CancelOrder)
            case createOrder(Matcher.Query.CreateOrder)
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
            
        case .cancelOrder(let order):
            return orderBookPath + "/" + order.amountAsset + "/" + order.priceAsset + "/" + "cancel"
            
        case .createOrder:
            return orderBookPath
        }
    }

    var method: Moya.Method {
        
        switch kind {
        case .cancelOrder, .createOrder:
            return .post
            
        default:
            return .get
        }
    }

    var task: Task {
        
        switch kind {
        case .cancelOrder(let order):
            return .requestParameters(parameters: order.params, encoding: JSONEncoding.default)
            
        case .createOrder(let order):
            return .requestParameters(parameters: order.params, encoding: JSONEncoding.default)

        default:
            return .requestPlain
        }
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
