//
//  CandleDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
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
        case h2 = 120
        case h3 = 180
        case h4 = 240
        case h6 = 360
        case h12 = 720
        case h24 = 1440
        case W1 = 10080 // 1 weak = 7 days
        case M1 = 44640 // 1 month = 31 days
        
        public static var all: [TimeFrameType] {
//TODO:             .W1, .M1 DontWork
            return [.m5, .m15, .m30, .h1, .h2, .h3, .h4, .h6, .h12, .h24]
        }
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
