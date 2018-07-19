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
        let name: String
        let quantity: Int64
        let decimals: Int
        let isFiat: Bool
    }

    struct Servers: Decodable {
        let nodeUrl: URL
        let dataUrl: URL
        let spamUrl: URL
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

    private static var _current: Environment?

    static let Testnet: Environment = parseJSON(json: Constants.test)!
    static let Mainnet: Environment = parseJSON(json: Constants.main)!
    static var current: Environment {
        get {
            if let cur = _current {
                return cur
            } else {
                if UserDefaults.standard.bool(forKey: "isTestEnvironment") {
                    _current = Testnet
                } else {
                    _current = Mainnet
                }
                return _current!
            }
        }
        set {
            if newValue.name == "Testnet" {
                UserDefaults.standard.set(true, forKey: "isTestEnvironment")
            } else {
                UserDefaults.standard.removeObject(forKey: "isTestEnvironment")
            }
            _current = newValue
        }
    }

    private static func parseJSON(json fileName: String) -> Environment? {
        let decoder = JSONDecoder()
        guard let path = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        guard let data = try? Data(contentsOf: path) else {
            return nil
        }

        return try? decoder.decode(Environment.self, from: data)
    }
}
