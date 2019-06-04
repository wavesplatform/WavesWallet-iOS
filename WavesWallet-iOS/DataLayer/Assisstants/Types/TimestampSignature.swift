//
//  TimestampSignature.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension
import WavesSDK
import Base58

fileprivate enum Constants {
    static let timestamp = "timestamp"    
    static let senderPublicKey = "senderPublicKey"
    static let signature = "signature"
}

struct TimestampSignature: SignatureProtocol {

    private(set) var signedWallet: DomainLayer.DTO.SignedWallet
    
    private(set) var timestamp: Int64
    
    var toSign: [UInt8] {
        let s1 = signedWallet.publicKey.publicKey
        let s2 = toByteArray(timestamp)
        return s1 + s2
    }
    
    var parameters: [String: String] {
        return [Constants.senderPublicKey: signedWallet.publicKey.getPublicKeyStr(),
                Constants.timestamp: "\(timestamp)",
                Constants.signature: signature()]
    }
}

extension TimestampSignature {
    init(signedWallet: DomainLayer.DTO.SignedWallet, environment: WalletEnvironment) {
        self.init(signedWallet: signedWallet,
                  timestamp: Date().millisecondsSince1970(timestampDiff: environment.timestampServerDiff))
    }
}

struct CreateOrderSignature: SignatureProtocol {
    
    struct AssetPair {
        let priceAssetId: String
        let amountAssetId: String
        
        func assetIdBytes(_ id: String) -> [UInt8] {
            return (id == WavesSDKCryptoConstants.wavesAssetId) ? [UInt8(0)] : ([UInt8(1)] + Base58.decode(id))
        }
        
        var bytes: [UInt8] {
            return assetIdBytes(amountAssetId) + assetIdBytes(priceAssetId)
        }
    }
    
    enum OrderType {
        
        case buy
        case sell
        
        var bytes: [UInt8] {
            switch self {
            case .sell: return [UInt8(1)]
            case .buy: return [UInt8(0)]
            }
        }
    }
    
    private(set) var signedWallet: DomainLayer.DTO.SignedWallet
    
    private(set) var timestamp: Int64

    private(set) var matcherPublicKey: PublicKeyAccount
    
    private(set) var assetPair: AssetPair
    
    private(set) var orderType: OrderType
    
    private(set) var price: Int64
    
    private(set) var amount: Int64
    
    private(set) var expiration: Int64
    
    private(set) var matcherFee: Int64
    
    var toSign: [UInt8] {
        let s1 = toByteArray(UInt8(2)) + signedWallet.publicKey.publicKey + matcherPublicKey.publicKey
        let s2 = assetPair.bytes + orderType.bytes
        let s3 = toByteArray(price) + toByteArray(amount)
        let s4 = toByteArray(timestamp) + toByteArray(expiration) + toByteArray(matcherFee)
        return s1 + s2 + s3 + s4
    }
    
//    private var id: [UInt8] {
//        return Hash.fastHash(toSign)
//    }
}

struct CancelOrderSignature: SignatureProtocol {
    
    private(set) var signedWallet: DomainLayer.DTO.SignedWallet
    
    private(set) var orderId: String
    
    var toSign: [UInt8] {
        let s1 = signedWallet.publicKey.publicKey
        let s2 = Base58.decode(orderId)
        return s1 + s2
    }
}


//fileprivate extension DomainLayer.Query.Dex.CancelOrder {
//
//    private var toSign: [UInt8] {
//        let s1 = wallet.publicKey.publicKey
//        let s2 = Base58.decode(orderId)
//        return s1 + s2
//    }
//
//    private var signature: [UInt8] {
//        return Hash.sign(toSign, wallet.privateKey.privateKey)
//    }
//
//    //TODO: Need we use proofs instead of signature?
//
//    var params: [String : String] {
//        return ["sender" : Base58.encode(wallet.publicKey.publicKey),
//                "orderId" : orderId,
//                "signature" : Base58.encode(signature)]
//    }
//}


//extension CreateOrderSignature {
//    
//    init(signedWallet: DomainLayer.DTO.SignedWallet,
//         timestamp: Int64,
//         matcherPublicKey: PublicKeyAccount,
//         assetPair: AssetPair,
//         orderType: OrderType,
//         price: Int64,
//         amount: Int64,
//         expiration: Int64,
//         matcherFee: Int64) {
//        
//        self.init(signedWallet: signedWallet,
//                  timestamp: timestamp,
//                  matcherPublicKey: matcherPublicKey,
//                  assetPair: assetPair,
//                  orderType: orderType,
//                  price: price,
//                  amount: amount,
//                  expiration: expiration,
//                  matcherFee: matcherFee)
//    }
//}


//fileprivate extension DomainLayer.Query.Dex.CreateOrder {
//
//    private struct AssetPair {
//        let amountAssetId: String?
//        let priceAssetId: String?
//
//        var json: [String : String] {
//            return ["amountAsset" : amountAssetId ?? "",
//                    "priceAsset" : priceAssetId ?? ""]
//        }
//
//        func assetIdBytes(_ id: String?) -> [UInt8] {
//            return id == nil ? [UInt8(0)] : ([UInt8(1)] + Base58.decode(id!))
//        }
//
//        var bytes: [UInt8] {
//            return assetIdBytes(amountAssetId) + assetIdBytes(priceAssetId)
//        }
//    }
//
//    private var assetPair: AssetPair {
//        return .init(amountAssetId: amountAsset == WavesSDKCryptoConstants.wavesAssetId ? nil : amountAsset,
//                     priceAssetId: priceAsset == WavesSDKCryptoConstants.wavesAssetId ? nil : priceAsset)
//    }
//
//    private var id: [UInt8] {
//        return Hash.fastHash(toSign)
//    }
//
//    private var expirationTimestamp: Int64 {
//        return timestamp + Int64(expiration) * 60 * 1000
//    }
//
//    private var signature: [UInt8] {
//        return Hash.sign(toSign, wallet.privateKey.privateKey)
//    }
//
//    private var toSign: [UInt8] {
//        let s1 = toByteArray(UInt8(2)) + wallet.publicKey.publicKey + matcherPublicKey.publicKey
//        let s2 = assetPair.bytes + orderType.bytes
//        let s3 = toByteArray(price) + toByteArray(amount)
//        let s4 = toByteArray(timestamp) + toByteArray(expirationTimestamp) + toByteArray(matcherFee)
//        return s1 + s2 + s3 + s4
//    }
//
//
//    var params: [String : Any] {
//
//        return ["senderPublicKey" :  Base58.encode(wallet.publicKey.publicKey),
//                "matcherPublicKey" : Base58.encode(matcherPublicKey.publicKey),
//                "assetPair" : assetPair.json,
//                "orderType" : orderType.rawValue,
//                "price" : price,
//                "amount" : amount,
//                "timestamp" : timestamp,
//                "expiration" : expirationTimestamp,
//                "matcherFee" : matcherFee,
//                "proofs" : [Base58.encode(signature)],
//                "version": 2]
//    }
//}
//
//
//fileprivate extension DomainLayer.DTO.Dex.OrderType {
//    var bytes: [UInt8] {
//        switch self {
//        case .sell: return [UInt8(1)]
//        case .buy: return [UInt8(0)]
//        }
//    }
//}
