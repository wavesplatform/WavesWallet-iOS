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

private enum Constants {
    static let cornerRadius: CGFloat = 3
    
    typealias ChartContants = DexChart.ChartContants
    typealias Candle = ChartContants.Candle
    typealias Bar = ChartContants.Bar
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
    @IBOutlet private weak var labelChartTopInfo: UILabel!
   
    private var state = DexChart.State.initialState
    var pair: DexTraderContainer.DTO.Pair!
    
    var presenter: DexChartPresenterProtocol!
    private let sendEvent: PublishRelay<DexChart.Event> = PublishRelay<DexChart.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.delegate = self
        setupLoadingState()
        setupFeedBack()
        setupChartsStyle()
        setupLocalization()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerView.createTopCorners(radius: Constants.cornerRadius)
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
                strongSelf.setupDefaultState()
                strongSelf.headerView.setupTimeFrame(timeFrame: state.timeFrame)
                strongSelf.setupLabelChartInfo()
            })
        
        return [subscriptionSections]
    }
}

//MARK: - SetupUI

private extension DexChartViewController {

    func setupLoadingState() {
        viewEmptyData.isHidden = true
        viewLoadingInfo.isHidden = false

        headerView.isHidden = true
        candleChartView.isHidden = true
        barChartView.isHidden = true
        labelChartTopInfo.isHidden = true
    }
    
    func setupDefaultState() {
        viewLoadingInfo.isHidden = true
        viewEmptyData.isHidden = state.isNotEmpty
        headerView.isHidden = !state.isNotEmpty
        candleChartView.isHidden = !state.isNotEmpty
        barChartView.isHidden = !state.isNotEmpty
        labelChartTopInfo.isHidden = !state.isNotEmpty
    }
    
    func setupLocalization() {
        labelLoadingData.text = Localizable.DexChart.Label.loadingChart
        labelEmptyData.text = Localizable.DexChart.Label.emptyData
    }
}

//MARK: - DexChartHeaderViewDelegate
extension DexChartViewController: DexChartHeaderViewDelegate {
    
    func dexChartDidChangeTimeFrame(_ timeFrame: DexChart.DTO.TimeFrameType) {
        
        candleChartView.data = nil
        candleChartView.notifyDataSetChanged()
        barChartView.data = nil
        barChartView.notifyDataSetChanged()
        
        setupLoadingState()
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
        
        setupLabelChartInfo()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
        if chartView == barChartView {
            candleChartView.highlightValue(nil)
        }
        else {
            barChartView.highlightValue(nil)
        }
        
        setupLabelChartInfo()
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
                
                if value == model.timestamp && !state.isPreloading {
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

    func setupLabelChartInfo() {
        
        let title = pair.amountAsset.name + " / " + pair.priceAsset.name
        
        if let highlighted = candleChartView.highlighted.first, state.candles.count > 0 {
            
            for model in state.candles {
                if model.timestamp == highlighted.x {
                    
                    labelChartTopInfo.text = String(format: "%@, %@, %@\nO: %0.8f, H: %0.8f,\nL: %0.8f, C: %0.8f, V: %0.6f",
                                                    title, state.timeFrame.shortText,
                                                    model.formatterTime(timeFrame: state.timeFrame),
                                                    model.open,
                                                    model.high,
                                                    model.low,
                                                    model.close,
                                                    model.volume)
                }
            }
            
        }
        else {
            labelChartTopInfo.text = "\(title), \(state.timeFrame.shortText)"
        }
    }
    
    func setupChartData() {
        
        if let formatter = candleChartView.xAxis.valueFormatter as? DexChartCandleAxisFormatter {
            formatter.timeFrame = state.timeFrame.rawValue
        }
        
        var candleYVals: [CandleChartDataEntry] = []
        var barYVals: [BarChartDataEntry] = []
        
        for model in state.candles {
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
