//
//  CandleApi.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {
    struct Chart: Decodable {
        
        struct Candle: Decodable {
            let time: Int64
            let volume: Double?
            let close: Double?
            let high: Double?
            let low: Double?
            let open: Double?            
        }
        
        let candles: [Candle]
    }
}
