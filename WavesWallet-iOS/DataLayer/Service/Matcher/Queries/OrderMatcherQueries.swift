//
//  OrderMatcherQueries.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Matcher.Query {
    
    struct CreateOrder {
        let wallet: DomainLayer.DTO.SignedWallet
        let matcherPublicKey: PublicKeyAccount
        let amountAsset: String
        let priceAsset: String
        let amount: Int64
        let price: Int64
        let orderType: DomainLayer.DTO.Dex.OrderType
        let matcherFee: Int
        let timestamp: Int64 = Date().millisecondsSince1970
        let expiration: Int
    }
    
    struct CancelOrder {
        let wallet: DomainLayer.DTO.SignedWallet
        let orderId: String
        let amountAsset: String
        let priceAsset: String
    }
}

//MARK: - CancelOrder
extension Matcher.Query.CancelOrder {
    
    private var toSign: [UInt8] {
        let s1 = wallet.publicKey.publicKey
        let s2 = Base58.decode(orderId)
        return s1 + s2
    }
    
    private var signature: [UInt8] {
        return Hash.sign(toSign, wallet.privateKey.privateKey)
    }
    
    var params: [String : String] {
        return ["sender" : Base58.encode(wallet.publicKey.publicKey),
                "orderId" : orderId,
                "signature" : Base58.encode(signature)]
    }
}



//MARK: - CreateOrder
extension Matcher.Query.CreateOrder {
    
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
        let s1 = wallet.publicKey.publicKey + matcherPublicKey.publicKey
        let s2 = assetPair.bytes + orderType.bytes
        let s3 = toByteArray(price) + toByteArray(amount)
        let s4 = toByteArray(timestamp) + toByteArray(expirationTimestamp) + toByteArray(matcherFee)
        return s1 + s2 + s3 + s4
    }
    
    private var expirationTimestamp: Int64 {
        return timestamp + Int64(expiration) * 60 * 1000
    }
    
    var params: [String : Any] {
        
        return ["id" : Base58.encode(id),
                "senderPublicKey" :  Base58.encode(wallet.publicKey.publicKey),
                "matcherPublicKey" : Base58.encode(matcherPublicKey.publicKey),
                "assetPair" : assetPair.json,
                "orderType" : orderType.rawValue,
                "price" : price,
                "amount" : amount,
                "timestamp" : timestamp,
                "expiration" : expirationTimestamp,
                "matcherFee" : matcherFee,
                "signature" : Base58.encode(signature)]
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
