//
//  DexChartBarRightAxisFormatter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Charts

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
