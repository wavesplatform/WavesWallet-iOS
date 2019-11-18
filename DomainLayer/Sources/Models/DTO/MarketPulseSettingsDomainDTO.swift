//
//  MarketPulseSettings.swift
//  DomainLayer
//
//  Created by Pavel Gubin on 29.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    
    struct MarketPulseSettings: Codable {
        
        public enum Interval: Int, Codable {
            case m1 = 60
            case m5 = 300
            case m10 = 600
            case manually = 0
        }
        
        public struct Asset: Codable {
            
            public let id: String
            public let name: String
            public let icon: AssetLogo.Icon
            public let amountAsset: String
            public let priceAsset: String
            
            
            public init(id: String, name: String, icon: AssetLogo.Icon, amountAsset: String, priceAsset: String) {
                self.id = id
                self.name = name
                self.icon = icon
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
