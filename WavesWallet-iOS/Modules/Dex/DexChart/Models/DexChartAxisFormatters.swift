//
//  DexChartCandleAxisValueFormatter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/1/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Charts
import DomainLayer

final class DexChartCandleRightAxisFormatter: IAxisValueFormatter {

    private var pair: DexTraderContainer.DTO.Pair

    init(pair: DexTraderContainer.DTO.Pair) {
        self.pair = pair
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let numberFormatter = DexChart.ViewModel.numberFormatter(pair: pair)
        
        if let string = numberFormatter.string(from: NSNumber(value: value)) {
            return string
        }
        return ""
    }
}

//MARK: - DexChartCandleAxisFormatter
final class DexChartCandleAxisFormatter: IAxisValueFormatter {
    
    private let dateFormatter = DateFormatter()
    
    var referenceTimeInterval: TimeInterval? = nil
    
    var candles: [DomainLayer.DTO.Candle]? = nil
        
    var timeFrame: DomainLayer.DTO.Candle.TimeFrameType? = nil {
        didSet {
            switch self.timeFrame {
            case .M1:
                dateFormatter.dateFormat = "MM yyyy"
            default:
                dateFormatter.dateFormat = "HH:mm\ndd.MM.yyyy"
            }
        }
    }
    
    private var timeFrameValue: Double {
        return Double(timeFrame?.seconds ?? 0)
    }
    
//    init(timeFrame: DomainLayer.DTO.Candle.TimeFrameType) {
//        self.timeFrame = timeFrame
//        
//        print(timeFrame)
//        switch self.timeFrame {
//        case .M1:
//            dateFormatter.dateFormat = "MM\nyyyy"
//        default:
//            dateFormatter.dateFormat = "HH:mm\ndd.MM.yyyy"
//        }
//    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                        
        let offSetX = (referenceTimeInterval ?? 0) / Double(timeFrame?.seconds ?? 0)
        
        print("Render value \(value) count \(candles?.count ?? 0) offSetX \(offSetX)")
//        if let candle = candles?[Int(value)] {
//            
//            
//            let date = candle.timestamp
//            print(date)
//            return dateFormatter.string(from: date)
//        }
        
//        let date = Date(timeIntervalSince1970: value * timeFrameValue + (referenceTimeInterval ?? 0))
        
        
//        let candle = axis?
        
        let date = Date(timeIntervalSince1970: value * 60.0 * Double(timeFrame?.rawValue ?? 0))
        
//        let xT = round(Double((model.timestamp.timeIntervalSince1970 * 1000) / (1000.0 * 60.0 * Double(timeFrame.rawValue))))
        
        return dateFormatter.string(from: date)
        
//        let time = value * 60 * timeFrameValue
//        let date = Date(timeIntervalSince1970: time)
//        return dateFormatter.string(from: date)
    }
}

//MARK: - DexChartBarAxisFormatter
final class DexChartBarAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return ""
    }
}


//MARK: - DexChartBarRightAxisFormatter
final class DexChartBarRightAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                
        if value == 0 {
            return String(Int(value))
        }
        else if value < 0.01 {
            return String(format: "%0.3f", value)
        }
        else if value < 0.1 {
            return String(format: "%0.2f", value)
        }
        else if value < 1 {
            return String(format: "%0.1f", value)
        }
        else if value < 10 {
            return String(Int(value))
        }
        else if value < 100 {
            return String(roundTo(value: value, to: 10))
        }
        else if value < 1000 {
            return String(roundTo(value: value, to: 100))
        }
        else {
            let val = roundTo(value: value, to: 1000)
            return String(val / 1000) + "K"
        }
    }
    
    private func roundTo(value: Double, to: Int) -> Int {
        return Int(Double(to) * floor(value / Double(to) + 0.5))
        
    }
}
