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
    enum ChartContants {}
    
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
        var isPreloading: Bool
        var isAppeared: Bool
    }
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

extension DexChart.DTO.Candle {
    
    func formatterTime(timeFrame: DexChart.DTO.TimeFrameType) -> String{
        let time = timestamp * 60 * Double(timeFrame.rawValue)
        let date = Date(timeIntervalSince1970: time)
        return DexChart.DTO.Candle.dateFormatter.string(from: date)
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
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
    
    var shortText: String {
        switch self {
        case .m5:
            return "M5"
            
        case .m15:
            return "M15"
            
        case .m30:
            return "M30"
            
        case .h1:
            return "H1"
            
        case .h4:
            return "H4"
            
        case .h24:
            return "H24"
        }
    }
}


extension DexChart.State {
    static var initialState: DexChart.State {
        
        let timeFrame = DexChart.DTO.TimeFrameType.m15
        
        let additionalTime : Double = Double(3600 * ((timeFrame.rawValue * 100) / 60))
        
        let dateTo = Date()
        let dateFrom = dateTo.addingTimeInterval(-additionalTime)
        
        return DexChart.State(action: .none, candles: [], timeFrame: timeFrame, dateFrom: dateFrom, dateTo: dateTo,
                              isPreloading: false, isAppeared: false)
    }
    
    var isNotEmpty: Bool {
        return candles.count > 0
    }
}

