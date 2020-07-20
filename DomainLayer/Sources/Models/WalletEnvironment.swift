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
}

public struct WalletEnvironment: Decodable, Hashable {
    public enum Kind: String, Hashable {
        case mainnet = "W"
        case testnet = "T"
        case wxdevnet = "S"

        public var chainId: String {
            return rawValue
        }

        public var chainIdByte: UInt8 {
            return rawValue.utf8.first ?? 0
        }
    }

    public struct AssetInfo: Decodable, Hashable {
        // TODO: подумать над такими обертками и убрать подобные?
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
        public let isStablecoin: Bool?
        public let isQualified: Bool?
        public let isExistInExternalSource: Bool?
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
            wavesExchangePublicApiUrl = wavesExchangeApiUrl
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
        return Kind(rawValue: scheme) ?? .mainnet
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
}
