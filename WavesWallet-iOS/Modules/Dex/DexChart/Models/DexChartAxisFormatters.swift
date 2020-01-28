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
        
    var timeFrame: DomainLayer.DTO.Candle.TimeFrameType? = nil
    
    var map: [String: DomainLayer.DTO.Candle]? = nil
    
    private var timeFrameValue: Double {
        return Double(timeFrame?.seconds ?? 0)
    }
    
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let key = "\(value)"
        guard let date = self.map?[key]?.timestamp else { return "" }
        guard let timeFrame = self.timeFrame else { return "" }
                        
        switch timeFrame {
        case .M1:
            if date.isThisYear {
                dateFormatter.dateFormat = "MMM"
            } else {
                dateFormatter.dateFormat = "MMM yyyy"
            }
            
        case .W1:
            if date.isThisYear {
                dateFormatter.dateFormat = "MMM dd"
            } else {
                dateFormatter.dateFormat = "MMM dd \n yyyy"
            }
            
        case .h1, .h2, .h3, .h4, .h6, .h12, .m5, .m15, .m30:
            dateFormatter.dateFormat = "HH:mm \n dd.MM.yyyy"
    
        case .h24:
            if date.isToday {
                return Localizable.Waves.Dexchart.Label.today
            } else if date.isYesterday {
                return Localizable.Waves.Dexchart.Label.yesterday
            } else {
                if date.isThisMonth {
                    dateFormatter.dateFormat = "E dd"
                } else {
                    dateFormatter.dateFormat = "E dd \n MMM yyyy"
                }
            }
        }
         
        return dateFormatter.string(from: date)
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
