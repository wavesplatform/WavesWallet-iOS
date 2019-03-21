//
//  Environment.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 28/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

struct Environment: Decodable {
    
    private static var timestampServerDiff: Int64 = 0
    
    enum Constants {
        static let alias = "alias"
        fileprivate static let main = "environment_mainnet"
        fileprivate static let test = "environment_testnet"
    }

    struct AssetInfo: Decodable {

        struct Icon: Decodable {
            let `default`: String?
        }

        let assetId: String
        let displayName: String
        let isFiat: Bool
        let isGateway: Bool
        let wavesId: String
        let gatewayId: String
        let addressRegEx: String
        let iconUrls: Icon?
    }

    struct Servers: Decodable {
        let nodeUrl: URL
        let dataUrl: URL
        let spamUrl: URL
        let matcherUrl: URL
    }

    let name: String
    let servers: Servers
    let scheme: String
    let generalAssetIds: [AssetInfo]
    
    private static let Testnet: Environment = parseJSON(json: Constants.test)!
    private static let Mainnet: Environment = parseJSON(json: Constants.main)!

    static var isTestNet: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isTestEnvironment")
            UserDefaults.standard.synchronize()
        }

        get {
            return UserDefaults.standard.bool(forKey: "isTestEnvironment")
        }
    }

    static var current: Environment {
        get {
            if isTestNet {
                return Testnet
            } else {
                return Mainnet
            }
        }
    }

    private static func parseJSON(json fileName: String) -> Environment? {
        return JSONDecoder.decode(json: fileName)
    }
}

extension Environment {

    var aliasScheme: String {
        return Constants.alias + ":" + scheme + ":"
    }
}

extension Environment {

    static func updateTimestampServerDiff(_ timestamp: Int64) {
        Environment.timestampServerDiff = timestamp
    }
    
    var timestampServerDiff: Int64 {
        return Environment.timestampServerDiff
    }
}
