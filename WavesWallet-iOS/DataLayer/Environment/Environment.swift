//
//  Environment.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 28/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

struct Environment: Decodable {
    struct AssetInfo: Decodable {
        let assetId: String
        let displayName: String
        let isFiat: Bool
        let isGateway: Bool
        let wavesId: String
        let gatewayId: String
        let regularExpression: String
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

final class Environments {
    enum Constants {
        static let wavesAssetId = "WAVES"
        fileprivate static let main = "Environment-Main"
        fileprivate static let test = "Environment-Test"
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
