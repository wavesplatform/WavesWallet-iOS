//
//  DexChartSettings.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 23.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import DomainLayer
import Extensions

struct DexChartSettings: TSUD {
    
    struct Settings: Codable {
        let timeFrame: Int
    }
    
    private static let key: String = "com.waves.dexChart.settings"
    
    static var defaultValue: Settings {
        return Settings(timeFrame: DomainLayer.DTO.Candle.TimeFrameType.m15.rawValue)
    }
    
    static var stringKey: String {
        return key
    }
    
    static var timeFrame: DomainLayer.DTO.Candle.TimeFrameType {
        guard let value = DomainLayer.DTO.Candle.TimeFrameType(rawValue: get().timeFrame) else {
            return .m15
        }
        
        return value
    }
    
    static func setTimeFrame(timeFrame: DomainLayer.DTO.Candle.TimeFrameType) {
        set(.init(timeFrame: timeFrame.rawValue))
    }
}
