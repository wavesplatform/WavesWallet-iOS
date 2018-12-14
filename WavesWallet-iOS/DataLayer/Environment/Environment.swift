//
//  Environment.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 28/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

struct Environment: Decodable {

    enum Constants {
        static let alias = "alias"
    }

    struct AssetInfo: Decodable {
        let assetId: String
        let displayName: String
        let isFiat: Bool
        let isGateway: Bool
        let wavesId: String
        let gatewayId: String
        let addressRegEx: String
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

    let isTestNet: Bool = {
        UserDefaults.standard.bool(forKey: "isTestEnvironment")
    }()
}

extension Environment {

    var aliasScheme: String {
        return Constants.alias + ":" + scheme + ":"
    }
}

final class Environments {
    enum Constants {
        fileprivate static let main = "environment_mainnet"
        fileprivate static let test = "environment_testnet"
    }

    static let Testnet: Environment = parseJSON(json: Constants.test)!
    static let Mainnet: Environment = parseJSON(json: Constants.main)!

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
