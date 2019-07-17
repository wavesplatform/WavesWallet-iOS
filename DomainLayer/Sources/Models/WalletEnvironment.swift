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
    
    static let vostokMainNetScheme = "V"
    static let vostokTestNetScheme = "F"
}

public struct WalletEnvironment: Decodable {
            
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
    
    private static let Testnet: WalletEnvironment = parseJSON(json: Constants.test)!
    private static let Mainnet: WalletEnvironment = parseJSON(json: Constants.main)!
    
    public static var isTestNet: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isTestEnvironment")
            UserDefaults.standard.synchronize()
        }
        
        get {
            return UserDefaults.standard.bool(forKey: "isTestEnvironment")
        }
    }
    
    public static var current: WalletEnvironment {
        get {
            if isTestNet {
                return Testnet
            } else {
                return Mainnet
            }
        }
    }
    
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
        return WalletEnvironment.isTestNet ? Constants.vostokTestNetScheme : Constants.vostokMainNetScheme
    }
}

