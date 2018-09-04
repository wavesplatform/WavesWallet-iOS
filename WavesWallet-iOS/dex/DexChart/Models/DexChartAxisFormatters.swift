//
//  DexChartCandleAxisValueFormatter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Charts


//MARK: - DexChartCandleAxisFormatter
final class DexChartCandleAxisFormatter: IAxisValueFormatter {
    
    private static let dateFormatter = DateFormatter()
    
    var timeFrame: Int = 0
    
    init() {
        DexChartCandleAxisFormatter.dateFormatter.dateFormat = "HH:mm\ndd.MM.yyyy"
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let time = value * 60 * Double(timeFrame)
        let date = Date(timeIntervalSince1970: time)
        return DexChartCandleAxisFormatter.dateFormatter.string(from: date)
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
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 5
        formatter.decimalSeparator = " "
        formatter.groupingSeparator = ","
        if let string = formatter.string(from: NSNumber(value: value)) {
            return string
        }
        return ""
    }
}
