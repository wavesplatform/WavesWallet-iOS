//
//  ChartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 05.07.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import Charts

protocol ChartViewControllerDelegate {

    func chartViewControllerDidChangeTimeFrame()
}

class ChartViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate : ChartViewControllerDelegate!
    
    var timeframe = DataManager.getCandleTimeFrame()
    var candles = NSMutableArray()
    
    var dateFrom = Date()
    var dateTo = Date()
    var isLoading = false
    var lastOffsetX : Double = 0
    
    
    @IBOutlet weak var candleChartView: CandleStickChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        candleChartView.delegate = self
        candleChartView.chartDescription?.enabled = false
        candleChartView.maxVisibleCount = 30
        candleChartView.pinchZoomEnabled = false
        candleChartView.scaleYEnabled = false
        candleChartView.autoScaleMinMaxEnabled = true
        candleChartView.leftAxis.enabled = false
        candleChartView.legend.enabled = false
        candleChartView.doubleTapToZoomEnabled = false
        candleChartView.drawGridBackgroundEnabled = false
        candleChartView.minOffset = 0
        candleChartView.noDataTextColor = UIColor.white
        
        candleChartView.scaleXEnabled = true
        candleChartView.scaleYEnabled = false
        candleChartView.autoScaleMinMaxEnabled = true
        
        let xAxis = candleChartView.xAxis;
        xAxis.labelPosition = .bottom;
        xAxis.gridLineWidth = 0.2
        xAxis.labelCount = 4
        xAxis.gridLineDashPhase = 0.1
        xAxis.gridLineDashLengths = [0.1, 0.3, 0.6]
        xAxis.gridLineCap = CGLineCap.butt
        xAxis.labelTextColor = UIColor.white
        xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        xAxis.valueFormatter = TimeAxisValueFormatter()
        
        let rightAxis = candleChartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelCount = 10
        rightAxis.gridLineWidth = 0.2
        rightAxis.gridLineDashPhase = 0.1
        rightAxis.gridLineDashLengths = [0.1, 0.3, 0.6]
        rightAxis.gridLineCap = CGLineCap.butt
        rightAxis.labelTextColor = UIColor.white
        rightAxis.labelFont = UIFont.systemFont(ofSize: 9)
        rightAxis.valueFormatter = ValueAxisValueFormatter()
        rightAxis.minWidth = 55
        rightAxis.maxWidth = 55
        
        candleChartView.isHidden = true
        preloadInfo {
            self.activityIndicator.stopAnimating()
            self.candleChartView.isHidden = false
            
            self.candleChartView.zoom(scaleX: 10, scaleY: 0, x:CGFloat.greatestFiniteMagnitude, y: 0)
        }
    }

    func nameFromTimeFrame(_ value: Int) -> String {
        
        if value == 1440 {
            return "D1"
        }
        else if value >= 60 {
            return "H\(value / 60)"
        }
        
        return "M\(value)"
    }
    
    func updateCandle() {
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.candleChartView.isHidden = true
        self.dateFrom = Date()
        
        let prevCount = self.candles.count
        self.candles.removeAllObjects()
        
        preloadInfo {
            self.activityIndicator.stopAnimating()
            self.candleChartView.isHidden = false
            
            let zoom = CGFloat(self.candles.count) * self.candleChartView.scaleX / CGFloat(prevCount)
            let additionalZoom = zoom / self.candleChartView.scaleX
            
            self.candleChartView.moveViewToAnimated(xValue: Double(CGFloat.greatestFiniteMagnitude), yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
            self.candleChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)
        }
    }
    
    func timeFrameTapped() {
        
        let controller = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = UIColor.black
        
        let cancelButton = UIAlertAction.init(title: nameFromTimeFrame(timeframe), style: .cancel, handler: nil)

        let buttonTime5 = UIAlertAction.init(title: nameFromTimeFrame(5), style: .default) { (action: UIAlertAction) in
          
            self.timeframe = 5
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime15 = UIAlertAction.init(title: nameFromTimeFrame(15), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 15
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime30 = UIAlertAction.init(title: nameFromTimeFrame(30), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 30
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime60 = UIAlertAction.init(title: nameFromTimeFrame(60), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 60
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime240 = UIAlertAction.init(title: nameFromTimeFrame(240), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 240
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        let buttonTime1440 = UIAlertAction.init(title: nameFromTimeFrame(1440), style: .default) { (action: UIAlertAction) in
            
            self.timeframe = 1440
            DataManager.setCandleTimeFrame(self.timeframe)
            self.delegate.chartViewControllerDidChangeTimeFrame()
            self.updateCandle()
        }
        
        controller.addAction(cancelButton)
        
        if timeframe != 5 {
            controller.addAction(buttonTime5)
        }
        if timeframe != 15 {
            controller.addAction(buttonTime15)
        }
        if timeframe != 30 {
            controller.addAction(buttonTime30)
        }
        if timeframe != 60 {
            controller.addAction(buttonTime60)
        }
        if timeframe != 240 {
            controller.addAction(buttonTime240)
        }
        if timeframe != 1440 {
            controller.addAction(buttonTime1440)
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    func calculateBeginEndDates() {
        dateTo = dateFrom
        let additionalTime : Double = Double(3600 * ((timeframe * 100) / 60))
        dateFrom = dateFrom.addingTimeInterval(-additionalTime)
    }
    
    func preloadInfo(complete: @escaping () -> Void) {
        
        if isLoading {
            return
        }
        
        isLoading = true
        calculateBeginEndDates()
        
        NetworkManager.getCandles(amountAsset: "WAVES", priceAsset: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", timeframe: timeframe, from: dateFrom, to: dateTo) { (items: NSArray?, errorMessage: String?) in
            
            self.isLoading = false
            
            if items != nil {
                self.setupData(items!)
                complete()
            }
        }
    }
    
    func setupData(_ items: NSArray) {
        
        let valueFormatter = candleChartView.xAxis.valueFormatter as! TimeAxisValueFormatter
        valueFormatter.timeFrame = timeframe

        let sortedItems = items.sortedArray(using: [NSSortDescriptor.init(key: "timestamp", ascending: true)])
        
        let yVals1 = NSMutableArray()

        for item in sortedItems {
            let model = CandleModel()
            model.setupModel(item as! NSDictionary, timeFrame: timeframe)
            
            if model.volume == 0 || candles.contains(model) {
                continue
            }
            
            candles.add(model)
        }
        
        candles.sort(using: [NSSortDescriptor.init(key: "timestamp", ascending: true)])
        
        for _model in candles {
            let model = _model as! CandleModel
            yVals1.add(CandleChartDataEntry(x: model.timestamp, shadowH:model.high , shadowL:model.low , open:model.open, close: model.close, data: model))
        }
        
        let set = CandleChartDataSet.init(values: yVals1 as? [ChartDataEntry], label: "Data Set")
        set.axisDependency = .right
        set.setColor(NSUIColor.init(cgColor: UIColor.init(white: 80/255, alpha: 1).cgColor))
        set.drawIconsEnabled = false
        set.drawValuesEnabled = false
        set.shadowWidth = 0.7;
        set.decreasingColor = UIColor(red: 228, green: 91, blue: 87)
        set.decreasingFilled = true
        set.increasingColor = UIColor(red: 98, green: 171, blue: 109)
        set.increasingFilled = true
        set.neutralColor = UIColor(red: 136, green: 226, blue: 247)
        set.shadowColorSameAsCandle = true
        
        candleChartView.data = CandleChartData.init(dataSet: set)
        self.candleChartView.notifyDataSetChanged()
    }

    
    //MARK: ChartViewDelegate
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(#function)
        
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print(#function)
        
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        print(#function)
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        if candles.count > 0 {
            
            let value = round(candleChartView.lowestVisibleX)
            let model = candles.firstObject as! CandleModel
            
            if value == model.timestamp && !isLoading {
                
                lastOffsetX = candleChartView.lowestVisibleX
                let prevCount = self.candles.count
                
                preloadInfo {
                    
                    if self.candles.count > prevCount {
                        
                        let zoom = CGFloat(self.candles.count) * self.candleChartView.scaleX / CGFloat(prevCount)
                        let additionalZoom = zoom / self.candleChartView.scaleX
                        
                        self.candleChartView.moveViewToAnimated(xValue: self.lastOffsetX, yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
                        self.candleChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)
                    }
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
