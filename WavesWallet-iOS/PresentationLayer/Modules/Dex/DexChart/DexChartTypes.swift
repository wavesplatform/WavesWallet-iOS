//
//  DexChartTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexChart {
    enum ViewModel {}
    enum ChartConstants {}
    
    enum Event {
        case readyView
        case didChangeTimeFrame(DomainLayer.DTO.Candle.TimeFrameType)
        case setCandles([DomainLayer.DTO.Candle])
        case preloading
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
            case changeTimeFrame
            case zoomAfterPreloading
            case zoomAfterTimeFrameChanged
        }
        
        var action: Action
        var candles: [DomainLayer.DTO.Candle]
        var timeFrame: DomainLayer.DTO.Candle.TimeFrameType
        var timeStart: Date
        var timeEnd: Date
        var isPreloading: Bool
        var isChangedTimeFrame: Bool
        var isNeedLoadingData: Bool
    }
}

extension DexChart.ViewModel {
    
    private static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.usesGroupingSeparator = false
        return numberFormatter
    }()
    
    static func numberFormatter(pair: DexTraderContainer.DTO.Pair) -> NumberFormatter {
        let formatter = numberFormatter
        formatter.minimumFractionDigits = pair.priceAsset.decimals
        formatter.maximumFractionDigits = pair.priceAsset.decimals
        return formatter
    }
}

extension DomainLayer.DTO.Candle {
    
    func formatterTime(timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> String{
        let time = timestamp * 60 * Double(timeFrame.rawValue)
        let date = Date(timeIntervalSince1970: time)
        return DomainLayer.DTO.Candle.dateFormatter.string(from: date)
    }
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
}


extension DomainLayer.DTO.Candle.TimeFrameType {
    
    var text: String {
        switch self {
        case .m5:
            return "5" + " " + Localizable.Waves.Dexchart.Label.minutes

        case .m15:
            return "15" + " " + Localizable.Waves.Dexchart.Label.minutes

        case .m30:
            return "30" + " " + Localizable.Waves.Dexchart.Label.minutes

        case .h1:
            return "1" + " " + Localizable.Waves.Dexchart.Label.hour

        case .h4:
            return "4" + " " + Localizable.Waves.Dexchart.Label.hours

        case .h24:
            return "24" + " " + Localizable.Waves.Dexchart.Label.hours
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
    
    static func additionalDate(start: Date, timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Date {
        let additionalTime : Double = Double(3600 * ((timeFrame.rawValue * 100) / 60))
        return start.addingTimeInterval(-additionalTime)
    }
    
    static func initialDateTo() -> Date {
        return Date()
    }
    
    static var initialState: DexChart.State {
        
        let timeFrame = DomainLayer.DTO.Candle.TimeFrameType.m15
        let dateTo = initialDateTo()
        let dateFrom = additionalDate(start: dateTo, timeFrame: timeFrame)
        
        return DexChart.State(action: .none,
                              candles: [],
                              timeFrame: timeFrame,
                              timeStart: dateFrom,
                              timeEnd: dateTo,
                              isPreloading: false,
                              isChangedTimeFrame: false,
                              isNeedLoadingData: false)
    }
    
    var isNotEmpty: Bool {
        return candles.count > 0
    }
}

extension DexChart.State: Equatable {
    static func == (lhs: DexChart.State, rhs: DexChart.State) -> Bool {
        return lhs.action == rhs.action &&
        lhs.candles == rhs.candles &&
        lhs.timeFrame == rhs.timeFrame &&
        lhs.timeStart == rhs.timeStart &&
        lhs.timeEnd == rhs.timeEnd &&
        lhs.isPreloading == rhs.isPreloading &&
        lhs.isNeedLoadingData == rhs.isNeedLoadingData
    }
}
