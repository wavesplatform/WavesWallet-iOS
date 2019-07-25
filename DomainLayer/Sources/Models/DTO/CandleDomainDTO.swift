//
//  CandleDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
   
    struct Candle {
        public let close: Double
        public let high: Double
        public let low: Double
        public let open: Double
        public let timestamp: Double
        public let volume: Double

        public init(close: Double, high: Double, low: Double, open: Double, timestamp: Double, volume: Double) {
            self.close = close
            self.high = high
            self.low = low
            self.open = open
            self.timestamp = timestamp
            self.volume = volume
        }
    }
}

public extension DomainLayer.DTO.Candle {
    enum TimeFrameType: Int {
        case m5 = 5
        case m15 = 15
        case m30 = 30
        case h1 = 60
        case h3 = 180
        case h24 = 1440
    }
}

extension DomainLayer.DTO.Candle: Equatable {
    public static func == (lhs: DomainLayer.DTO.Candle, rhs: DomainLayer.DTO.Candle) -> Bool {
        return lhs.close == rhs.close &&
            lhs.high == rhs.high &&
            lhs.low == rhs.low &&
            lhs.open == rhs.open &&
            lhs.timestamp == rhs.timestamp &&
            lhs.volume == rhs.volume
    }
}
