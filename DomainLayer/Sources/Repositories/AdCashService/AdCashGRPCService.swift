//
//  AdCashService.swift
//  DomainLayer
//
//  Created by vvisotskiy on 20.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

public struct ACashAsset: Codable {
    public enum Kind: Int, Codable {
        case crypto
        case fiat
        case unrecognized
    }
    
    public let id: String
    public let name: String
    public let kind: Kind
    public let decimals: Int32
    
    public init(id: String, name: String, kind: Kind, decimals: Int32) {
        self.id = id
        self.name = name
        self.kind = kind
        self.decimals = decimals
    }
}

///
public protocol AdCashGRPCService: AnyObject {
    
    ///
    func getACashAssets(signedWallet: SignedWallet, completion: @escaping (Result<[ACashAsset], Error>) -> Void)
    
    ///
    func getACashAssetsExchangeRate(signedWallet: SignedWallet,
                                    senderAsset: String,
                                    recipientAsset: String,
                                    senderAssetAmount: Double,
                                    completion: @escaping (Result<Double, Error>) -> Void)
}
