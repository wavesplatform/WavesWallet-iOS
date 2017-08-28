//
//  Environment.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 28/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

struct AssetInfo {
    let assetId: String
    let name: String
    let quantity: Int64
    let decimals: Int
    
    init(_ assetId: String, _ name: String, _ quantity: Int64, _ decimals: Int) {
        self.assetId = assetId
        self.name = name
        self.quantity = quantity
        self.decimals = decimals
    }

}

struct Environment {
    let name: String
    let nodeUrl: URL
    let scheme: String
    let generalAssetIds: [AssetInfo]
    
    init(_ name: String, _ nodeUrl: String, _ scheme: String, _ generalAssetIds: [AssetInfo]) {
        self.name = name
        self.nodeUrl = URL(string: nodeUrl)!
        self.scheme = scheme
        self.generalAssetIds = generalAssetIds
    }
    
    let isTestNet: Bool = {
        return UserDefaults.standard.bool(forKey: "isTestEnvironment")
    }()
 
}

class Environments {
    static let Testnet = Environment("Testnet", "http://52.30.47.67:6869", "T",
        [AssetInfo("", "WAVES", 10000000000000000, 8),
         AssetInfo("Fmg13HEHJHuZYbtJq8Da8wifJENq8uBxDuWoP9pVe2Qe", "BTC", 2100000000000000, 8),
         AssetInfo("HyFJ3rrq5m7FxdkWtQXkZrDat1F7LjVVGfpSkUuEXQHj", "USD", 100000000000, 2),
         AssetInfo("2xnE3EdpqXtFgCP156qt1AbyjpqdZ5jGjWo3CwTawcux", "EUR", 100000000000, 2)
        ])

    static let Mainnet = Environment("Mainnet", "https://nodes.wavesnodes.com", "W",
        [AssetInfo("", "WAVES", 10000000000000000, 8),
         AssetInfo("8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 2100000000000000, 8),
         AssetInfo("Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 100000000000, 2),
         AssetInfo("Gtb1WRznfchDnTh37ezoDTJ4wcoKaRsKqKjJjy7nm2zU", "EUR", 100000000000, 2),
         AssetInfo("DHgwrRvVyqJsepd32YbBqUeDH4GJ1N984X8QoekjgH8J", "WCT", 1000000000, 2),
         AssetInfo("4uK8i4ThRGbehENwa6MxyLtxAjAo1Rj9fduborGExarC", "MRT", 1000000000, 2)
        ])
    
    private static var _current: Environment?
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
        } set(newValue) {
            if newValue.name == "Testnet" {
                UserDefaults.standard.set(true, forKey: "isTestEnvironment")
            } else {
                UserDefaults.standard.removeObject(forKey: "isTestEnvironment")
            }
            _current = newValue
        }
    }

}
