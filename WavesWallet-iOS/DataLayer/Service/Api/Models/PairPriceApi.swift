//
//  PairApi.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {
    
    struct PairPrice: Decodable {
        let firstPrice: Double
        let lastPrice: Double
        let volume: Double
        let volumeWaves: Double?
    
        static var empty: PairPrice {
            return PairPrice(firstPrice: 0,
                            lastPrice: 0,
                            volume: 0,
                            volumeWaves: 0)
        }
    }
}
