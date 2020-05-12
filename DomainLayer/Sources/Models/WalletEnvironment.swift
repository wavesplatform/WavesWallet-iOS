//
//  Environment.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 28/04/2017.
//  Copyright © 2017 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDKExtensions

private enum Constants {
    static let alias = "alias"
    fileprivate static let mainnet = "environment_mainnet"
    fileprivate static let testnet = "environment_testnet"
    fileprivate static let stagenet = "environment_stagenet"
    
    fileprivate static let mainnet_test = "environment_mainnet_test"
    fileprivate static let testnet_test = "environment_testnet_test"
    fileprivate static let stagenet_test = "environment_stagenet_test"
    
}

public struct WalletEnvironment: Decodable, Hashable {
    
    public enum Kind: String, Hashable {
        case mainnet = "W"
        case testnet = "T"
        case stagenet = "S"
        
        public var chainId: String {
            return rawValue
        }
                
    }
        
    public struct AssetInfo: Decodable, Hashable {
        
        public struct Icon: Decodable, Hashable {
            public let `default`: String?
        }
        
        public let assetId: String
        public let displayName: String
        public let isFiat: Bool
        public let isGateway: Bool
        public let wavesId: String
        public let gatewayId: String
        public let addressRegEx: String
        public let iconUrls: Icon?
        public let gatewayType: String?
    }
    
    public struct Servers: Decodable, Hashable {
            
        public struct Gateways: Decodable, Hashable {
            public let v0: URL
            public let v1: URL
            public let v2: URL
        }
        
        public let nodeUrl: URL
        public let dataUrl: URL
        public let spamUrl: URL
        public let matcherUrl: URL
        public let gatewayUrl: URL
        public let authUrl: URL
        public let gateways: Gateways
        
        public let wavesExchangePublicApiUrl: URL
        public let wavesExchangeInternalApiUrl: URL
        public let wavesExchangeGrpcAddress: String
        public let firebaseAuthApiUrl: URL
        
        public init(nodeUrl: URL,
                    dataUrl: URL,
                    spamUrl: URL,
                    matcherUrl: URL,
                    gatewayUrl: URL,
                    authUrl: URL,
                    gateways: Gateways,
                    wavesExchangeApiUrl: URL,
                    wavesExchangeGrpcAddress: String,
                    firebaseAuthApiUrl: URL,
                    wavesExchangeInternalApiUrl: URL) {
            
            self.nodeUrl = nodeUrl
            self.dataUrl = dataUrl
            self.spamUrl = spamUrl
            self.matcherUrl = matcherUrl
            self.gatewayUrl = gatewayUrl
            self.authUrl = authUrl
            self.gateways = gateways
            self.wavesExchangePublicApiUrl = wavesExchangeApiUrl
            self.wavesExchangeGrpcAddress = wavesExchangeGrpcAddress
            self.wavesExchangeInternalApiUrl = wavesExchangeInternalApiUrl
            self.firebaseAuthApiUrl = firebaseAuthApiUrl
        }
    }
    
    public let name: String
    public let servers: Servers
    public let scheme: String
    public let generalAssets: [AssetInfo]
    public let assets: [AssetInfo]?
    
    public var kind: Kind {
        return Kind.init(rawValue: scheme) ?? .mainnet
    }
    
    public static let Testnet: WalletEnvironment = parseJSON(json: Constants.testnet)!
    public static let Mainnet: WalletEnvironment = parseJSON(json: Constants.mainnet)!
    public static let Stagenet: WalletEnvironment = parseJSON(json: Constants.stagenet)!
    
    public static let TestnetTest: WalletEnvironment = parseJSON(json: Constants.testnet_test)!
    public static let MainnetTest: WalletEnvironment = parseJSON(json: Constants.mainnet_test)!
    public static let StagenetTest: WalletEnvironment = parseJSON(json: Constants.stagenet_test)!
    
    public init(name: String,
                servers: Servers,
                scheme: String,
                generalAssets: [AssetInfo],
                assets: [AssetInfo]?) {
        
        self.name = name
        self.servers = servers
        self.scheme = scheme
        self.generalAssets = generalAssets
        self.assets = assets
    }
    
    private static func parseJSON(json fileName: String) -> WalletEnvironment? {
        return JSONDecoder.decode(json: fileName)
    }
    
}

public extension WalletEnvironment {
    
    var aliasScheme: String {
        return Constants.alias + ":" + scheme + ":"
    }
}

