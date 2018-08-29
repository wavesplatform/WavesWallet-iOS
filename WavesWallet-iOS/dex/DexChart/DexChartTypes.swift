//
//  DexChartTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexChart {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case readyView
        case didChangeTimeFrame(DTO.TimeFrameType)
        case setCandles([DTO.Candle])
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var action: Action
        var candles: [DTO.Candle]
        var timeFrame: DTO.TimeFrameType
        var dateFrom: Date
        var dateTo: Date
        var isLoading: Bool
    }
}

extension DexChart.ViewModel {
    
}

extension DexChart.DTO {
    
    enum TimeFrameType: Int {
        case m5 = 5
        case m15 = 15
        case m30 = 30
        case h1 = 60
        case h4 = 240
        case h24 = 1440
    }
    
    struct Candle {
        let close: Double
        let confirmed: Bool
        let high: Double
        let low: Double
        let open: Double
        let priceVolume: Double
        let timestamp: Double
        let volume: Double
        let vwap: Double
    }
}

extension DexChart.DTO.TimeFrameType {
    
    var text: String {
        switch self {
        case .m5:
            return "5" + " " + Localizable.DexChart.Label.minutes

        case .m15:
            return "15" + " " + Localizable.DexChart.Label.minutes

        case .m30:
            return "30" + " " + Localizable.DexChart.Label.minutes

        case .h1:
            return "1" + " " + Localizable.DexChart.Label.hour

        case .h4:
            return "4" + " " + Localizable.DexChart.Label.hours

        case .h24:
            return "24" + " " + Localizable.DexChart.Label.hours
        }
    }
}


extension DexChart.State {
    static var initialState: DexChart.State {
        
        let additionalTime : Double = Double(3600 * ((5 * 100) / 60))
        
        let dateTo = Date()
        let dateFrom = dateTo.addingTimeInterval(-additionalTime)
        
        return DexChart.State(action: .none, candles: [], timeFrame: .m5, dateFrom: dateFrom, dateTo: dateTo, isLoading: false)
    }
}

