//
//  ChartModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 18.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import Charts

class CandleModel : NSObject {

    var close : Double = 0
    var high : Double = 0
    var low : Double = 0
    var open : Double = 0
    var volume : Double = 0
    var timestamp : Double = 0
    
    func setupModel(_ item : NSDictionary, timeFrame: Int) {
        
        close = Double((item["close"] as? String)!)!
        high = Double((item["high"] as? String)!)!
        low = Double((item["low"] as? String)!)!
        open = Double((item["open"] as? String)!)!
        volume = Double((item["volume"] as? String)!)!

        if let timeS = item["timestamp"] as? Double {
            timestamp = timeS / Double(1000 * 60 * timeFrame)
        }
        else if (item["timestamp"] as? String) != nil {
            timestamp = Double((item["timestamp"] as? String)!)! / Double(1000 * 60 * timeFrame)
        }
    }
}

class CandleTimeAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    var timeFrame = 0
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let time = value * 60 * Double(timeFrame)
        let date = Date.init(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm\ndd.MM.yyyy"
        return formatter.string(from: date)
    }
}


class CandleAxisValueFormatter: NSObject, IAxisValueFormatter {

    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {

        return String(format: "%0.6f", value)
    }
}

class BarAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    let numberFormatter = NumberFormatter()

    override init() {
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .decimal
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return numberFormatter.string(for: value)!
    }
}
