//
//  DexChartConstants.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension DexChart.ChartContants {

    enum Candle {}
    enum Bar {}
    
    static let gridLineWidth: CGFloat = 0.2
}


extension DexChart.ChartContants.Candle {
    
    enum DataSet {
        static let decreasingColor = UIColor.error400
        static let increasingColor = UIColor.submit300
        static let highlightLineWidth: CGFloat = 0.5
        static let highlightColor = UIColor.basic700
        static let highlightLineDashLengths: [CGFloat] = [5, 5]
        static let shadowWidth: CGFloat = 0.7
    }
    
    enum RightAxis {
        static let labelCount = 7
        static let labelTextColor = UIColor.basic700
        static let labelFont = UIFont.systemFont(ofSize: 10)
    }
    
    enum xAxis {
        static let labelCount = 4
        static let labelFont = UIFont.systemFont(ofSize: 10)
        static let labelTextColor = UIColor.basic500
    }
}

extension DexChart.ChartContants.Bar {
    
    enum DataSet {
        static let color = UIColor.basic300
        static let highlightColor = UIColor.basic700
        static let barWidth: Double = 0.8
    }
    
    enum RightAxis {
        static let labelCount = 4
        static let labelTextColor = UIColor.basic700
        static let labelFont = UIFont.systemFont(ofSize: 10)
    }
}

