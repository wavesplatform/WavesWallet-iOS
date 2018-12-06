//
//  CandleDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
   
    struct Candle {
        let close: Double
        let high: Double
        let low: Double
        let open: Double
        let timestamp: Double
        let volume: Double
    }
}

extension DomainLayer.DTO.Candle {
    enum TimeFrameType: Int {
        case m5 = 5
        case m15 = 15
        case m30 = 30
        case h1 = 60
        case h4 = 240
        case h24 = 1440
    }
}

extension DomainLayer.DTO.Candle: Equatable {
    static func == (lhs: DomainLayer.DTO.Candle, rhs: DomainLayer.DTO.Candle) -> Bool {
        return lhs.close == rhs.close &&
            lhs.high == rhs.high &&
            lhs.low == rhs.low &&
            lhs.open == rhs.open &&
            lhs.timestamp == rhs.timestamp &&
            lhs.volume == rhs.volume
    }
}
