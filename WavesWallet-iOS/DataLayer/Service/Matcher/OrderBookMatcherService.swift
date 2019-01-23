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
            case getOrderBook(amountAsset: String, priceAsset: String)
            case getMarket
            case getMyOrders(amountAsset: String, priceAsset: String, signature: TimestampSignature)
            case cancelOrder(DomainLayer.Query.Dex.CancelOrder)
            case createOrder(DomainLayer.Query.Dex.CreateOrder)
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



//MARK: - CancelOrder
fileprivate extension DomainLayer.Query.Dex.CancelOrder {
    
    private var toSign: [UInt8] {
        let s1 = wallet.publicKey.publicKey
        let s2 = Base58.decode(orderId)
        return s1 + s2
    }
    
    private var signature: [UInt8] {
        return Hash.sign(toSign, wallet.privateKey.privateKey)
    }
    
    //TODO: Need we use proofs instead of signature?
    
    var params: [String : String] {
        return ["sender" : Base58.encode(wallet.publicKey.publicKey),
                "orderId" : orderId,
                "signature" : Base58.encode(signature)]
    }
}



//MARK: - CreateOrder
fileprivate extension DomainLayer.Query.Dex.CreateOrder {
    
    private struct AssetPair {
        let amountAssetId: String?
        let priceAssetId: String?
        
        var json: [String : String] {
            return ["amountAsset" : amountAssetId ?? "",
                    "priceAsset" : priceAssetId ?? ""]
        }
        
        func assetIdBytes(_ id: String?) -> [UInt8] {
            return id == nil ? [UInt8(0)] : ([UInt8(1)] + Base58.decode(id!))
        }
        
        var bytes: [UInt8] {
            return assetIdBytes(amountAssetId) + assetIdBytes(priceAssetId)
        }
    }
    
    private var assetPair: AssetPair {
        return .init(amountAssetId: amountAsset == GlobalConstants.wavesAssetId ? nil : amountAsset,
                     priceAssetId: priceAsset == GlobalConstants.wavesAssetId ? nil : priceAsset)
    }
    
    private var id: [UInt8] {
        return Hash.fastHash(toSign)
    }
    
    private var signature: [UInt8] {
        return Hash.sign(toSign, wallet.privateKey.privateKey)
    }
    
    private var toSign: [UInt8] {
        let s1 = toByteArray(UInt8(2)) + wallet.publicKey.publicKey + matcherPublicKey.publicKey
        let s2 = assetPair.bytes + orderType.bytes
        let s3 = toByteArray(price) + toByteArray(amount)
        let s4 = toByteArray(timestamp) + toByteArray(expirationTimestamp) + toByteArray(Int64(matcherFee))
        return s1 + s2 + s3 + s4
    }
    
    private var expirationTimestamp: Int64 {
        return timestamp + Int64(expiration) * 60 * 1000
    }
//    message    String    GenericError(Script doesn't exist and proof doesn't validate as signature for OrderV1(3PCAB4sHXgvtu5NPoen6EXR5yaNbvsEA8Fj,3PJaDyprvekvPXPuAtxrapacuDJopgJRaU3,WAVES-Gtb1WRznfchDnTh37ezoDTJ4wcoKaRsKqKjJjy7nm2zU,sell,100000000,100000000,1548258429304,1550764029304,300000,Proofs(List(2QnTnJ1sTQEJYb5DbgJSsTXpyLLmbTMKzxab4GufPUtD9fXTWKwzYJzvkh4FmcnJmAY7rBYm1Lw6NzvCLUmzBZxk))))
    var params: [String : Any] {
        
        return ["senderPublicKey" :  Base58.encode(wallet.publicKey.publicKey),
                "matcherPublicKey" : Base58.encode(matcherPublicKey.publicKey),
                "assetPair" : assetPair.json,
                "orderType" : orderType.rawValue,
                "price" : price,
                "amount" : amount,
                "timestamp" : timestamp,
                "expiration" : expirationTimestamp,
                "matcherFee" : matcherFee,
                "proofs" : [Base58.encode(signature)],
                "version:": 2]
    }
}


fileprivate extension DomainLayer.DTO.Dex.OrderType {
    var bytes: [UInt8] {
        switch self {
        case .sell: return [UInt8(1)]
        case .buy: return [UInt8(0)]
        }
    }
}
