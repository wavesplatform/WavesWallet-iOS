//
//  DexChartSettings.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Charts

private enum Constants {    
    typealias ChartContants = DexChart.ChartContants
    typealias Candle = ChartContants.Candle
    typealias Bar = ChartContants.Bar
}

final class DexChartSettings {
    
    //MARK: - Data
    
    func setupChartData(candleChartView: CandleStickChartView, barChartView: BarChartView,
                        timeFrame: DexChart.DTO.TimeFrameType,
                        candles: [DexChart.DTO.Candle]) {
        
        if let formatter = candleChartView.xAxis.valueFormatter as? DexChartCandleAxisFormatter {
            formatter.timeFrame = timeFrame.rawValue
        }
        
        var candleYVals: [CandleChartDataEntry] = []
        var barYVals: [BarChartDataEntry] = []
        
        for model in candles {
            candleYVals.append(CandleChartDataEntry(x: model.timestamp, shadowH:model.high , shadowL: model.low , open:model.open, close: model.close))
            barYVals.append(BarChartDataEntry(x: model.timestamp, y: model.volume))
        }
        
        let candleSet = CandleChartDataSet(values: candleYVals, label: nil)
        candleSet.axisDependency = .right
        candleSet.setColor(NSUIColor.init(cgColor: UIColor.init(white: 80/255, alpha: 1).cgColor))
        candleSet.drawIconsEnabled = false
        candleSet.drawValuesEnabled = false
        candleSet.shadowWidth = Constants.Candle.DataSet.shadowWidth
        candleSet.decreasingColor = Constants.ChartContants.decreasingColor
        candleSet.decreasingFilled = true
        candleSet.increasingColor = Constants.ChartContants.increasingColor
        candleSet.increasingFilled = true
        candleSet.neutralColor = Constants.ChartContants.neutralColor
        candleSet.shadowColorSameAsCandle = true
        candleSet.drawHorizontalHighlightIndicatorEnabled = false
        candleSet.highlightLineWidth = Constants.Candle.DataSet.highlightLineWidth
        candleSet.highlightColor = Constants.Candle.DataSet.highlightColor
        candleSet.colors = [UIColor.blue, UIColor.red]
        
        if candleSet.entryCount > 0 {
            candleChartView.data = CandleChartData(dataSet: candleSet)
            candleChartView.notifyDataSetChanged()
        }
        
        let barSet = BarChartDataSet(values: barYVals, label: nil)
        barSet.axisDependency = .right
        barSet.drawIconsEnabled = false
        barSet.drawValuesEnabled = false
        barSet.highlightColor = Constants.Bar.DataSet.highlightColor
        barSet.setColor(Constants.Bar.DataSet.color)
        
        let barData = BarChartData(dataSet: barSet)
        barData.barWidth = 0.80
        if barData.entryCount > 0 {
            barChartView.data = barData
            barChartView.notifyDataSetChanged()
        }
    }
    
    
    //MARK: - UI
    
    func setupChartStyle(candleChartView: CandleStickChartView, barChartView: BarChartView) {

        candleChartView.chartDescription?.enabled = false
        candleChartView.pinchZoomEnabled = false
        candleChartView.scaleYEnabled = false
        candleChartView.scaleXEnabled = true
        candleChartView.autoScaleMinMaxEnabled = true
        candleChartView.autoScaleMinMaxEnabled = true
        candleChartView.leftAxis.enabled = false
        candleChartView.legend.enabled = false
        candleChartView.doubleTapToZoomEnabled = false
        candleChartView.drawGridBackgroundEnabled = false
        candleChartView.noDataText = ""
        
        candleChartView.xAxis.labelPosition = .bottom;
        candleChartView.xAxis.gridLineWidth = Constants.ChartContants.gridLineWidth
        candleChartView.xAxis.labelCount = Constants.Candle.xAxis.labelCount
        candleChartView.xAxis.labelTextColor = Constants.Candle.xAxis.labelTextColor
        candleChartView.xAxis.labelFont = Constants.Candle.xAxis.labelFont
        candleChartView.xAxis.valueFormatter = DexChartCandleAxisFormatter()
        candleChartView.xAxis.granularityEnabled = true
        candleChartView.xAxis.granularityEnabled = true
        
        candleChartView.rightAxis.enabled = true
        candleChartView.rightAxis.labelCount = Constants.Candle.RightAxis.labelCount
        candleChartView.rightAxis.gridLineWidth = Constants.ChartContants.gridLineWidth
        candleChartView.rightAxis.labelTextColor = Constants.Candle.RightAxis.labelTextColor
        candleChartView.rightAxis.labelFont = Constants.Candle.RightAxis.labelFont
        candleChartView.rightAxis.valueFormatter = CandleAxisValueFormatter()
        candleChartView.rightAxis.minWidth = Constants.ChartContants.minWidth
        candleChartView.rightAxis.maxWidth = Constants.ChartContants.maxWidth
        candleChartView.rightAxis.forceLabelsEnabled = true
        
        barChartView.chartDescription?.enabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.scaleXEnabled = true
        barChartView.autoScaleMinMaxEnabled = true
        barChartView.leftAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.noDataText = ""
        
        barChartView.rightAxis.enabled = true
        barChartView.rightAxis.labelCount = Constants.Bar.RightAxis.labelCount
        barChartView.rightAxis.gridLineWidth = Constants.ChartContants.gridLineWidth
        barChartView.rightAxis.labelTextColor = Constants.Bar.RightAxis.labelTextColor
        barChartView.rightAxis.labelFont = Constants.Bar.RightAxis.labelFont
        barChartView.rightAxis.valueFormatter = BarAxisValueFormatter()
        barChartView.rightAxis.minWidth = Constants.ChartContants.maxWidth
        barChartView.rightAxis.maxWidth = Constants.ChartContants.maxWidth
        barChartView.rightAxis.axisMinimum = 0
        barChartView.rightAxis.forceLabelsEnabled = true
        
        barChartView.xAxis.gridLineWidth = Constants.ChartContants.gridLineWidth
        barChartView.xAxis.valueFormatter = DexChartBarAxisFormatter()
        barChartView.xAxis.labelPosition = .bottom;
    }
}
