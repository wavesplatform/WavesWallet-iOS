//
//  DexChartViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Charts
import RxSwift
import RxCocoa
import RxFeedback
import SwiftyJSON

private enum Contants {
    static let cornerRadius: CGFloat = 3
}

final class DexChartViewController: UIViewController {

    @IBOutlet private weak var viewEmptyData: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var candleChartView: CandleStickChartView!
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private weak var headerView: DexChartHeaderView!
    @IBOutlet private weak var labelEmptyData: UILabel!
    @IBOutlet private weak var labelLoadingData: UILabel!
    @IBOutlet private weak var viewLoadingInfo: UIView!
        
    private var state = DexChart.State.initialState

    
    var presenter: DexChartPresenterProtocol!
    private let sendEvent: PublishRelay<DexChart.Event> = PublishRelay<DexChart.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewEmptyData.isHidden = true
        viewLoadingInfo.isHidden = true
        
        
        headerView.delegate = self
        setupFeedBack()
        setupChartsStyle()
        setupLocalization()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerView.createTopCorners(radius: Contants.cornerRadius)
    }
}


// MARK: Feedback

fileprivate extension DexChartViewController {
    
    func setupFeedBack() {
    
        let feedback = bind(self) { owner, state -> Bindings<DexChart.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: DexChartPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in DexChart.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    func events() -> [Signal<DexChart.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<DexChart.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                guard state.action != .none else { return }
                
                strongSelf.state = state
                strongSelf.setupChartData()
            })
        
        return [subscriptionSections]
    }
}

//MARK: - SetupUI

private extension DexChartViewController {

    func setupLoadingState() {
        
    }
    
    func setupLocalization() {
        labelLoadingData.text = Localizable.DexChart.Label.loadingChart
        labelEmptyData.text = Localizable.DexChart.Label.emptyData
    }
}

//MARK: - DexChartHeaderViewDelegate
extension DexChartViewController: DexChartHeaderViewDelegate {
    
    func dexChartDidChangeTimeFrame(_ timeFrame: DexChart.DTO.TimeFrameType) {
        sendEvent.accept(.didChangeTimeFrame(timeFrame))
    }
}

extension DexChartViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        if chartView == barChartView {
            candleChartView.highlightValue(chartView.highlighted.first)
        }
        else {
            barChartView.highlightValue(chartView.highlighted.first)
        }
        
//        setupLabelCandleInfo()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
        if chartView == barChartView {
            candleChartView.highlightValue(nil)
        }
        else {
            barChartView.highlightValue(nil)
        }
        
//        setupLabelCandleInfo()
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
        if chartView == candleChartView {
            barChartView.zoom(scaleX: candleChartView.scaleX, scaleY: candleChartView.scaleY, xValue: 0, yValue: 0, axis: YAxis.AxisDependency.right)
            barChartView.moveViewToX(candleChartView.lowestVisibleX)
        }
        else {
            candleChartView.zoom(scaleX: barChartView.scaleX, scaleY: barChartView.scaleY, xValue: 0, yValue: 0, axis: YAxis.AxisDependency.right)
            candleChartView.moveViewToX(barChartView.lowestVisibleX)
        }
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        if chartView == candleChartView {
            barChartView.moveViewToX(candleChartView.lowestVisibleX)
        }
        else {
            candleChartView.moveViewToX(barChartView.lowestVisibleX)
        }
        
        if state.candles.count > 10 {
            
            let value = round(candleChartView.lowestVisibleX)
            
            if let model = state.candles.first {
                
                if value == model.timestamp && !state.isLoading {
//                    lastOffsetX = candleChartView.lowestVisibleX
//                    let prevCount = self.candles.count
//                    
//                    preloadInfo {
//                        
//                        if self.candles.count > prevCount {
//                            
//                            let zoom = CGFloat(self.candles.count) * self.candleChartView.scaleX / CGFloat(prevCount)
//                            let additionalZoom = zoom / self.candleChartView.scaleX
//                            
//                            self.candleChartView.moveViewToAnimated(xValue: self.lastOffsetX, yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
//                            self.candleChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)
//                            
//                            self.barChartView.moveViewToAnimated(xValue: self.lastOffsetX, yValue: 0, axis: YAxis.AxisDependency.right, duration: 0.00001)
//                            self.barChartView.zoomToCenter(scaleX: additionalZoom, scaleY: 0)
//                        }
//                    }
                }
            }
            
           
        }
        
//        setupLimitLinePosition()
        
    }
    
}


//MARK: - Setup Charts
private extension DexChartViewController {

    func setupChartData() {
        
        let valueFormatter = candleChartView.xAxis.valueFormatter as! CandleTimeAxisValueFormatter
        valueFormatter.timeFrame = state.timeFrame.rawValue
        
//        self.state.candles = state.candles.sorted(by: {$0.timestamp < $1.timestamp})

//        candles.sort(using: [NSSortDescriptor.init(key: "timestamp", ascending: true)])
        
        var candleYVals: [CandleChartDataEntry] = []
        var barYVals: [BarChartDataEntry] = []
        
        for model in state.candles {
            candleYVals.append(CandleChartDataEntry(x: model.timestamp, shadowH:model.high , shadowL: model.low , open:model.open, close: model.close))
            barYVals.append(BarChartDataEntry(x: model.timestamp, y: model.volume))
        }
        
        let candleSet = CandleChartDataSet(values: candleYVals, label: "")
        candleSet.axisDependency = .right
        candleSet.setColor(NSUIColor.init(cgColor: UIColor.init(white: 80/255, alpha: 1).cgColor))
        candleSet.drawIconsEnabled = false
        candleSet.drawValuesEnabled = false
        candleSet.shadowWidth = 0.7;
        candleSet.decreasingColor = UIColor.error400
        candleSet.decreasingFilled = true
        candleSet.increasingColor = UIColor.submit300
        candleSet.increasingFilled = true
        candleSet.neutralColor = UIColor.black// UIColor(red: 136, green: 226, blue: 247)
        candleSet.shadowColorSameAsCandle = true
        candleSet.drawHorizontalHighlightIndicatorEnabled = false
        candleSet.highlightLineWidth = 0.4
        
        if candleSet.entryCount > 0 {
            candleChartView.data = CandleChartData(dataSet: candleSet)
            candleChartView.notifyDataSetChanged()
        }
        
        let barSet = BarChartDataSet(values: barYVals, label: "")
        barSet.axisDependency = .right
        barSet.drawIconsEnabled = false
        barSet.drawValuesEnabled = false
        barSet.highlightColor = UIColor(red: 103, green: 105, blue: 111)
        barSet.setColor(UIColor(red: 195, green: 199, blue: 210))
        
        let barData = BarChartData(dataSet: barSet)
        barData.barWidth = 0.80
        barChartView.data = barData
        barChartView.notifyDataSetChanged()
    }
    
    
    func setupChartsStyle() {
        candleChartView.delegate = self
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
        candleChartView.noDataTextColor = UIColor.white
        
        candleChartView.xAxis.labelPosition = .bottom;
        candleChartView.xAxis.gridLineWidth = 0.2
        candleChartView.xAxis.labelCount = 4
        candleChartView.xAxis.labelTextColor = UIColor.darkGray
        candleChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        candleChartView.xAxis.valueFormatter = CandleTimeAxisValueFormatter()
        candleChartView.xAxis.granularityEnabled = true
        
        candleChartView.rightAxis.enabled = true
        candleChartView.rightAxis.labelCount = 10
        candleChartView.rightAxis.gridLineWidth = 0.2
        candleChartView.rightAxis.labelTextColor = UIColor.darkGray
        candleChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 8)
        candleChartView.rightAxis.valueFormatter = CandleAxisValueFormatter()
        candleChartView.rightAxis.minWidth = 55
        candleChartView.rightAxis.maxWidth = 55
        candleChartView.rightAxis.forceLabelsEnabled = true
        
        barChartView.delegate = self
        barChartView.chartDescription?.enabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.scaleYEnabled = false
        barChartView.scaleXEnabled = true
        barChartView.autoScaleMinMaxEnabled = true
        barChartView.leftAxis.enabled = false
        barChartView.legend.enabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.noDataTextColor = UIColor.white
        barChartView.noDataText = ""
        
        barChartView.rightAxis.enabled = true
        barChartView.rightAxis.labelCount = 4
        barChartView.rightAxis.gridLineWidth = 0.2
        barChartView.rightAxis.labelTextColor = UIColor.darkGray
        barChartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 8)
        barChartView.rightAxis.valueFormatter = BarAxisValueFormatter()
        barChartView.rightAxis.minWidth = 55
        barChartView.rightAxis.maxWidth = 55
        barChartView.rightAxis.axisMinimum = 0
        barChartView.rightAxis.forceLabelsEnabled = true
        
        barChartView.xAxis.gridLineWidth = 0.2
        barChartView.xAxis.valueFormatter = BarAxisSpaceFormatter()
        barChartView.xAxis.labelPosition = .bottom;
    }
    
}
