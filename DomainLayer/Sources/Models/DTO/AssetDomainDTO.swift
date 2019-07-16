//
//  File.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    
    struct Asset: Mutating, Equatable {
        
        public struct Icon: Equatable {
            public let assetId: String
            public let name: String
            public let url: String?

            public init(assetId: String, name: String, url: String?) {
                self.assetId = assetId
                self.name = name
                self.url = url
            }
        }

        public let id: String
        public let gatewayId: String?
        public let wavesId: String?
        public let displayName: String
        public let precision: Int
        public let description: String
        public let height: Int64
        public let timestamp: Date
        public let sender: String
        public let quantity: Int64
        public let ticker: String?
        public let isReusable: Bool
        public var isSpam: Bool
        public let isFiat: Bool
        public let isGeneral: Bool
        public let isMyWavesToken: Bool
        public let isWavesToken: Bool
        public let isGateway: Bool
        public let isWaves: Bool
        public let modified: Date
        public let addressRegEx: String
        public let iconLogoUrl: String?
        public let hasScript: Bool
        public var minSponsoredFee: Int64
        public let gatewayType: DomainLayer.DTO.GatewayType?
        
        public init(id: String, gatewayId: String?, wavesId: String?, displayName: String, precision: Int, description: String, height: Int64, timestamp: Date, sender: String, quantity: Int64, ticker: String?, isReusable: Bool, isSpam: Bool, isFiat: Bool, isGeneral: Bool, isMyWavesToken: Bool, isWavesToken: Bool, isGateway: Bool, isWaves: Bool, modified: Date, addressRegEx: String, iconLogoUrl: String?, hasScript: Bool, minSponsoredFee: Int64, gatewayType: String?) {
            
            self.id = id
            self.gatewayId = gatewayId
            self.wavesId = wavesId
            self.displayName = displayName
            self.precision = precision
            self.description = description
            self.height = height
            self.timestamp = timestamp
            self.sender = sender
            self.quantity = quantity
            self.ticker = ticker
            self.isReusable = isReusable
            self.isSpam = isSpam
            self.isFiat = isFiat
            self.isGeneral = isGeneral
            self.isMyWavesToken = isMyWavesToken
            self.isWavesToken = isWavesToken
            self.isGateway = isGateway
            self.isWaves = isWaves
            self.modified = modified
            self.addressRegEx = addressRegEx
            self.iconLogoUrl = iconLogoUrl
            self.hasScript = hasScript
            self.minSponsoredFee = minSponsoredFee
            self.gatewayType = DomainLayer.DTO.GatewayType(rawValue: gatewayType ?? "")
        }
    }
}

public extension DomainLayer.DTO.Asset {

    var iconLogo: DomainLayer.DTO.Asset.Icon {
        return DomainLayer.DTO.Asset.Icon(assetId: id, name: icon, url: iconLogoUrl)
    }

    var icon: String {

        if let gatewayId = gatewayId, gatewayId.count > 0 {
            return gatewayId
        }
        
        return displayName
    }
    
    var isMonero: Bool {
        return gatewayId == "XMR"
    }
    
    var isEthereum: Bool {
        return gatewayId == "ETH"
    }
    
    var isVostok: Bool {
        return gatewayId == "Vostok"
    }
    
    var isSponsored: Bool {
        return minSponsoredFee > 0
    }
}
