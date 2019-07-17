//
//  TimestampSignature.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 23.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDK
import WavesSDKCrypto
import DomainLayer
import Extensions

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
    init(signedWallet: DomainLayer.DTO.SignedWallet, timestampServerDiff: Int64) {
        self.init(signedWallet: signedWallet,
                  timestamp: Date().millisecondsSince1970(timestampDiff: timestampServerDiff))
    }
}

struct CreateOrderSignature: SignatureProtocol {
    
    struct AssetPair {
        let priceAssetId: String
        let amountAssetId: String
        
        func assetIdBytes(_ id: String) -> [UInt8] {
            return (id == WavesSDKConstants.wavesAssetId) ? [UInt8(0)] : ([UInt8(1)] + Base58Encoder.decode(id))
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
    
    enum Version: Int {
        case V2 = 2
        case V3 = 3
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
    
    private(set) var matcherFeeAsset: String

    private(set) var version: Version

    var toSign: [UInt8] {
                
        let s1 = toByteArray(UInt8(version.rawValue)) + signedWallet.publicKey.publicKey + matcherPublicKey.publicKey
        let s2 = assetPair.bytes + orderType.bytes
        let s3 = toByteArray(price) + toByteArray(amount)
        let s4 = toByteArray(timestamp) + toByteArray(expiration) + toByteArray(matcherFee)
        
        var result = s1 + s2 + s3 + s4
        
        if version == .V3 {
            result += [UInt8(1)] + (WavesCrypto.shared.base58decode(input: matcherFeeAsset) ?? [])
        }
        
        return result
    }
    
    private var id: [UInt8] {
        return Hash.fastHash(toSign)
    }
}

struct CancelOrderSignature: SignatureProtocol {
    
    private(set) var signedWallet: DomainLayer.DTO.SignedWallet
    
    private(set) var orderId: String
    
    var toSign: [UInt8] {
        let s1 = signedWallet.publicKey.publicKey
        let s2 = Base58Encoder.decode(orderId)
        return s1 + s2
    }
}

