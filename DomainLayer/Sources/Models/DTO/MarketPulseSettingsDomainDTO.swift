//
//  MarketPulseSettings.swift
//  DomainLayer
//
//  Created by Pavel Gubin on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    
    public struct MarketPulseSettings {
        
        public enum Interval: Int {
            case m1 = 60
            case m5 = 300
            case m10 = 600
            case manually = 0
        }
        
        public struct Asset {
            
            public struct IconStyle {
                public let icon: DomainLayer.DTO.Asset.Icon
                public let isSponsored: Bool
                public let hasScript: Bool
                
                public init(icon: DomainLayer.DTO.Asset.Icon, isSponsored: Bool, hasScript: Bool) {
                    self.icon = icon
                    self.isSponsored = isSponsored
                    self.hasScript = hasScript
                }
            }
            
            public let id: String
            public let name: String
            public let iconStyle: IconStyle
            public let amountAsset: String
            public let priceAsset: String
            
            public init(id: String, name: String, iconStyle: IconStyle, amountAsset: String, priceAsset: String) {
                self.id = id
                self.name = name
                self.iconStyle = iconStyle
                self.amountAsset = amountAsset
                self.priceAsset = priceAsset
            }
        }
        
        public let isDarkStyle: Bool
        public let interval: Interval
        public let assets: [Asset]
        
        public init(isDarkStyle: Bool, interval: Interval, assets: [Asset]) {
            self.isDarkStyle = isDarkStyle
            self.interval = interval
            self.assets = assets
        }
    }
}
