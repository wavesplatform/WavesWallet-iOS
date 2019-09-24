//
//  Environment.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 28/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions

private enum Constants {
    static let alias = "alias"
    fileprivate static let main = "environment_mainnet"
    fileprivate static let test = "environment_testnet"
    fileprivate static let stage = "environment_stagenet"
    
    static let vostokMainNetScheme = "V"
    static let vostokTestNetScheme = "F"
}

//TODO: Rename ?
public struct WalletEnvironment: Decodable {
    
    public enum Kind: String {
        case mainnet = "W"
        case testnet = "T"
        case stagenet = "S"
        
        public var chainId: String {
            return rawValue
        }
                
    }
    
    public struct AssetInfo: Decodable {
        
        public struct Icon: Decodable {
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
    
    public struct Servers: Decodable {
        public let nodeUrl: URL
        public let dataUrl: URL
        public let spamUrl: URL
        public let matcherUrl: URL
        public let gatewayUrl: URL
        
        public init(nodeUrl: URL,
                    dataUrl: URL,
                    spamUrl: URL,
                    matcherUrl: URL,
                    gatewayUrl: URL) {
            
            self.nodeUrl = nodeUrl
            self.dataUrl = dataUrl
            self.spamUrl = spamUrl
            self.matcherUrl = matcherUrl
            self.gatewayUrl = gatewayUrl
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
    
    public static let Testnet: WalletEnvironment = parseJSON(json: Constants.test)!
    public static let Mainnet: WalletEnvironment = parseJSON(json: Constants.main)!
    public static let Stagenet: WalletEnvironment = parseJSON(json: Constants.main)!
    
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
    
    var vostokScheme: String {
        return self.kind == .testnet ? Constants.vostokTestNetScheme : Constants.vostokMainNetScheme
    }
}

