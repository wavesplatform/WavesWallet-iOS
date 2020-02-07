//
//  TradeCategoryConfig.swift
//  DomainLayer
//
//  Created by Pavel Gubin on 16.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
 
    struct TradeCategory {
        
        public struct Filter: Equatable {
            public let name: String
            public let ids: [String]
            
            public init(name: String, ids: [String]) {
                self.name = name
                self.ids = ids
            }
        }
        
        public let name: String
        public let filters: [Filter]
        public let pairs: [DomainLayer.DTO.Dex.Pair]
        public let matchingAssets: [DomainLayer.DTO.Dex.Asset]
                    
        public init(name: String,
                    filters: [Filter],
                    pairs: [DomainLayer.DTO.Dex.Pair],
                    matchingAssets: [DomainLayer.DTO.Dex.Asset]) {
            self.name = name
            self.filters = filters
            self.pairs = pairs
            self.matchingAssets = matchingAssets
        }
    }
}
