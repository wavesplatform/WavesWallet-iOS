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
    let spamUrl: URL = URL(string: "https://github-proxy.wvservices.com/wavesplatform/WavesGUI/client-907-fix-portfolio/scam.csv")!
    
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
         AssetInfo("474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 10000000000000000, 8),
         AssetInfo("Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 100000000000, 2),
         AssetInfo("Gtb1WRznfchDnTh37ezoDTJ4wcoKaRsKqKjJjy7nm2zU", "EUR", 100000000000, 2),
         AssetInfo("HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk", "LTC", 8400000000000000, 8),
         AssetInfo("BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa", "ZEC", 2100000000000000, 8),
         AssetInfo("zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy", "BCH", 2100000000000000, 8),
         AssetInfo("2mX5DzVKWrAJw8iwdJnV2qtoeVG9h5nTDpTqC1wb1WEN", "TRY", 100000000, 2),
         AssetInfo("B3uGHFRpSUuGEDWjqB9LWWxafQj8VTvpMucEyoxzws5H", "DASH", 1890000000000000, 8),
         AssetInfo("5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3", "XMR", 1603984700000000, 8)
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
