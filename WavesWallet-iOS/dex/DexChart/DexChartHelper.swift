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
    
    static let defaultZoomScale: CGFloat = 8
}

final class DexChartHelper {

    private var hasInitFirstTimeZoom = false
    private var prevCandlesCount = 0
    
    static let minCountCandlesToZoom = 10
}


//MARK: - Data
extension DexChartHelper {
    
    
    func setupChartData(candleChartView: CandleStickChartView, barChartView: BarChartView, timeFrame: DexChart.DTO.TimeFrameType, candles: [DexChart.DTO.Candle]) {
        
        if let formatter = candleChartView.xAxis.valueFormatter as? DexChartCandleAxisFormatter {
            formatter.timeFrame = timeFrame.rawValue
        }
        
        var candleYVals: [CandleChartDataEntry] = []
        var barYVals: [BarChartDataEntry] = []
        
        for model in candles {
            candleYVals.append(CandleChartDataEntry(x: model.timestamp, shadowH: model.high , shadowL: model.low , open:model.open, close: model.close))
            barYVals.append(BarChartDataEntry(x: model.timestamp, y: model.volume))
        }
        
        let candleSet = CandleChartDataSet(values: candleYVals, label: nil)
        candleSet.axisDependency = .right
        candleSet.drawIconsEnabled = false
        candleSet.drawValuesEnabled = false
        candleSet.shadowWidth = Constants.Candle.DataSet.shadowWidth
        candleSet.decreasingColor = Constants.Candle.DataSet.decreasingColor
        candleSet.decreasingFilled = true
        candleSet.increasingColor = Constants.Candle.DataSet.increasingColor
        candleSet.increasingFilled = true
        candleSet.neutralColor = Constants.Candle.DataSet.increasingColor
        candleSet.shadowColorSameAsCandle = true
        candleSet.highlightLineWidth = Constants.Candle.DataSet.highlightLineWidth
        candleSet.highlightColor = Constants.Candle.DataSet.highlightColor
        candleSet.highlightLineDashLengths = Constants.Candle.DataSet.highlightLineDashLengths
        candleSet.drawHorizontalHighlightIndicatorEnabled = false
        
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
        barData.barWidth = Constants.Bar.DataSet.barWidth
        if barData.entryCount > 0 {
            barChartView.data = barData
            barChartView.notifyDataSetChanged()
        }
    }
}

//MARK: - Setup UI
extension DexChartHelper {

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
        candleChartView.xAxis.drawAxisLineEnabled = false
        
        candleChartView.rightAxis.enabled = true
        candleChartView.rightAxis.labelCount = Constants.Candle.RightAxis.labelCount
        candleChartView.rightAxis.gridLineWidth = Constants.ChartContants.gridLineWidth
        candleChartView.rightAxis.labelTextColor = Constants.Candle.RightAxis.labelTextColor
        candleChartView.rightAxis.labelFont = Constants.Candle.RightAxis.labelFont
        candleChartView.rightAxis.valueFormatter = CandleAxisValueFormatter()
        candleChartView.rightAxis.minWidth = Constants.ChartContants.minWidth
        candleChartView.rightAxis.maxWidth = Constants.ChartContants.maxWidth
        candleChartView.rightAxis.forceLabelsEnabled = true
        candleChartView.rightAxis.drawAxisLineEnabled = false
        
        
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
        barChartView.rightAxis.valueFormatter = DexChartBarRightAxisFormatter()
        barChartView.rightAxis.drawAxisLineEnabled = false

        barChartView.xAxis.gridLineWidth = Constants.ChartContants.gridLineWidth
        barChartView.xAxis.valueFormatter = DexChartBarAxisFormatter()
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawAxisLineEnabled = false
    }
}

//MARK: - Zoom
extension DexChartHelper {
    
    func updateAfterTimeFrameChanged(candleChartView: CandleStickChartView, barChartView: BarChartView, candles: [DexChart.DTO.Candle]) {
        
        if candles.count > 1 {

            let newZoom = 1 / candleChartView.scaleX * Constants.defaultZoomScale
       
            candleChartView.moveViewToAnimated(xValue: Double.greatestFiniteMagnitude, yValue: 0, axis: YAxis.AxisDependency.right,
                                               duration: Double.leastNormalMagnitude)

            barChartView.moveViewToAnimated(xValue: Double.greatestFiniteMagnitude, yValue: 0, axis: YAxis.AxisDependency.right,
                                            duration: Double.leastNormalMagnitude)

            candleChartView.zoomToCenter(scaleX: newZoom, scaleY: 0)
            barChartView.zoomToCenter(scaleX: newZoom, scaleY: 0)

            candleChartView.highlightValue(nil)
            barChartView.highlightValue(nil)
        }
        
        prevCandlesCount = candles.count
    }
    
    func zoom(candleChartView: CandleStickChartView, barChartView: BarChartView, candles: [DexChart.DTO.Candle], lowestVisibleX: Double) {
        
        if candles.count > prevCandlesCount {
            
            let zoom = CGFloat(candles.count) * candleChartView.scaleX / CGFloat(prevCandlesCount)
            let additionalZoom = zoom / candleChartView.scaleX
            
            candleChartView.moveViewToAnimated(xValue: lowestVisibleX, yValue: 0, axis: YAxis.AxisDependency.right,
                                               duration: Double.leastNormalMagnitude)
            candleChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)

            barChartView.moveViewToAnimated(xValue: lowestVisibleX, yValue: 0, axis: YAxis.AxisDependency.right,
                                            duration: Double.leastNormalMagnitude)
            barChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)
        }
        
        prevCandlesCount = candles.count
    }
    
    func setupInitialZoom(candleChartView: CandleStickChartView, barChartView: BarChartView, candles: [DexChart.DTO.Candle]) {
        
        if hasInitFirstTimeZoom {
            return
        }
        hasInitFirstTimeZoom = true
        
        if candles.count > DexChartHelper.minCountCandlesToZoom {
            candleChartView.zoom(scaleX: Constants.defaultZoomScale, scaleY: 0, x: CGFloat.greatestFiniteMagnitude, y: 0)
            barChartView.zoom(scaleX: Constants.defaultZoomScale, scaleY: 0, x: CGFloat.greatestFiniteMagnitude, y: 0)
        }
        
        prevCandlesCount = candles.count
    }
}

//MARK: - Other
extension DexChartHelper {
    
    func lastVisibleCandleInfo(candleChartView: CandleStickChartView) -> (positionY: CGFloat, color: UIColor, price: Double) {

        var color = UIColor.clear
        var positionY: CGFloat = 0
        var price: Double = 0
        
        if let dataSet = candleChartView.candleData?.dataSets.first {
            
            var barSpace: Double = 0
           
            if let dataSet = candleChartView.candleData?.dataSets.first as? CandleChartDataSet {
                barSpace = Double(dataSet.barSpace)
            }
            
            let highestVisibleX = candleChartView.highestVisibleX - barSpace
            
            if let entry = dataSet.entryForXValue(highestVisibleX, closestToY: 0) as? CandleChartDataEntry {
               
                price = entry.close

                if let trans = candleChartView.rightYAxisRenderer.transformer?.valueToPixelMatrix {
                    var position = CGPoint(x: 0.0, y: CGFloat(entry.close))
                    position = position.applying(trans)
                    positionY = position.y
                }
                
                if entry.open > entry.close {
                    color = Constants.Candle.DataSet.decreasingColor
                }
                else {
                    color = Constants.Candle.DataSet.increasingColor
                }
            }
        }
        
        return (positionY, color, price)
    }
    
    func highlightedCandleInfo(candleChartView: CandleStickChartView, highlightedView: UIView, state: DexChart.State) -> (positionY: CGFloat, topTitle: String, price: Double) {
        
        var title = ""
        var price: Double = 0
        var positionY: CGFloat = 0
        
        if let highlighted = candleChartView.highlighted.first, state.candles.count > 0 {
            
            if let candle = state.candles.first(where: {$0.timestamp == highlighted.x}) {
                
                price = candle.close
                
                title = String(format: "%@, %@\nO: %0.8f, H: %0.8f,\nL: %0.8f, C: %0.8f, V: %0.6f",
                                        state.timeFrame.shortText,
                                        candle.formatterTime(timeFrame: state.timeFrame),
                                        candle.open,
                                        candle.high,
                                        candle.low,
                                        candle.close,
                                        candle.volume)
                
                
                if let trans = candleChartView.rightYAxisRenderer.transformer?.valueToPixelMatrix {
                    var position = CGPoint(x: 0.0, y: CGFloat(candle.close))
                    position = position.applying(trans)
                    positionY = position.y - highlightedView.frame.size.height / 2
                }
                
                let bottomAxisHeight: CGFloat = 28
                let minimumTopPostition: CGFloat = 2
                
                if positionY < minimumTopPostition {
                    positionY = minimumTopPostition
                }
                else if positionY > candleChartView.frame.size.height - bottomAxisHeight {
                    positionY = candleChartView.frame.size.height - bottomAxisHeight - highlightedView.frame.size.height / 2
                }
            }
        }
        
        return (positionY, title, price)
    }
}
