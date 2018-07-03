//
//  AssetChartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Charts

class DateAxisValueFormatter: NSObject, IAxisValueFormatter {
    
    let dateFormatter = DateFormatter()
    
    override init() {
        dateFormatter.dateFormat = "dd.MM"
    }
    
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

class AssetChartViewController: UIViewController, ChartViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var viewDotter: UIView!
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var dotterTopOffset: NSLayoutConstraint!
    @IBOutlet weak var dotterLeftOffset: NSLayoutConstraint!
    
    @IBOutlet weak var viewChartView: UIView!
    @IBOutlet weak var leadingChartView: NSLayoutConstraint!
    
    var selectedChartPediod = AssetViewController.ChartPeriod.day
    
    @IBOutlet weak var labelPeriod: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewChartView.layer.shadowColor = UIColor.black.cgColor
        viewChartView.layer.shadowOffset = CGSize(width: 0, height: 3)
        viewChartView.layer.shadowRadius = 3
        viewChartView.layer.shadowOpacity = 0.2
        viewChartView.layer.cornerRadius = 3
        viewChartView.isHidden = true
        viewDotter.isHidden = true
        
        chartView.chartDescription?.enabled = false
        chartView.pinchZoomEnabled = false
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.minOffset = 0
        chartView.noDataText = ""
        chartView.delegate = self
        chartView.highlightPerTapEnabled = false
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = DateAxisValueFormatter()
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 10)
        chartView.xAxis.labelTextColor = UIColor.info500
        chartView.xAxis.labelCount = 4
        chartView.xAxis.centerAxisLabelsEnabled = true
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        
        let values = (0..<50).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(10) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let set = LineChartDataSet(values: values, label: "DataSet")
        set.drawValuesEnabled = false
        set.drawIconsEnabled = false
        set.drawCirclesEnabled = false
        set.setColor(.submit300)
        set.lineWidth = 2
        set.highlightLineWidth = 1
        set.highlightColor = .submit300
        set.drawHorizontalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSet: set)
        
        chartView.data = data
    
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handler(_:)))
        longPress.minimumPressDuration = 0
        longPress.delegate = self
        chartView.addGestureRecognizer(longPress)
        
        updatePeriod()
    }

    func getChartPediodText() -> String {
        
        if selectedChartPediod == .day {
            return "Day"
        }
        else if selectedChartPediod == .week {
            return "Week"
        }
        return "Month"
    }
    
    func updatePeriod() {
        labelPeriod.text = "\(getChartPediodText()) status"
    }
    
    @IBAction func changePeriodTapped(_ sender: Any) {
        let controller = UIAlertController(title: "Choose period", message: nil, preferredStyle: .actionSheet)
        let day = UIAlertAction(title: "Day", style: .default) { (action) in
            
            if self.selectedChartPediod == .day {
                return
            }
            self.selectedChartPediod = .day
            self.updatePeriod()
        }
        let week = UIAlertAction(title: "Week", style: .default) { (action) in
            
            if self.selectedChartPediod == .week {
                return
            }
            self.selectedChartPediod = .week
            self.updatePeriod()
        }
        let month = UIAlertAction(title: "Month", style: .default) { (action) in
            
            if self.selectedChartPediod == .month {
                return
            }
            self.selectedChartPediod = .month
            self.updatePeriod()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        controller.addAction(day)
        controller.addAction(week)
        controller.addAction(month)
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        dotterTopOffset.constant = highlight.yPx - viewDotter.frame.size.width / 2.0
        dotterLeftOffset.constant = highlight.xPx - viewDotter.frame.size.width / 2.0
        
        leadingChartView.constant = highlight.xPx - viewChartView.frame.size.width - 10
        
        if leadingChartView.constant < 5 {
            leadingChartView.constant = highlight.xPx + 10
        }
        
        if #available(iOS 10.0, *) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func handler(_ gesture: UIGestureRecognizer) {
        
        if gesture.state == .began {
            viewDotter.isHidden = false
            viewChartView.isHidden = false

            let h = chartView.getHighlightByTouchPoint(gesture.location(in: chartView))
            
            if h === nil || h!.isEqual(chartView.lastHighlighted)
            {
                chartView.highlightValue(nil, callDelegate: true)
                chartView.lastHighlighted = nil
            }
            else
            {
                chartView.highlightValue(h, callDelegate: true)
                chartView.lastHighlighted = h
            }
        }
        else if gesture.state == .ended {
            self.chartView.highlightValues(nil)
            viewDotter.isHidden = true
            viewChartView.isHidden = true
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}
