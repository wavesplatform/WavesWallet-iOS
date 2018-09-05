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
    
    @IBOutlet private weak var viewLastVisibleCandle: DexChartCandlePriceView!
    @IBOutlet private weak var viewLastVisibleCandleOffset: NSLayoutConstraint!
    
    private var chartHelper = DexChartHelper()
    private var state = DexChart.State.initialState
    private let sendEvent: PublishRelay<DexChart.Event> = PublishRelay<DexChart.Event>()

    var pair: DexTraderContainer.DTO.Pair!
    var presenter: DexChartPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.delegate = self
        setupLoadingState()
        setupFeedBack()
        setupCharts()
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
                strongSelf.headerView.setupTimeFrame(timeFrame: state.timeFrame)
                strongSelf.setupCandleChartInfo()
                strongSelf.setupChartData(state: state)
                
                if state.action == .changeTimeFrame {
                    strongSelf.setupUpdatingState()
                }
                else {
                    strongSelf.setupDefaultState()
                }
            })
        
        return [subscriptionSections]
    }
}

//MARK: - SetupUI

private extension DexChartViewController {

    func setupLimitLinePosition() {
        
//        viewLastCandlePriceOffset.constant = chartHelper.lastPricePosition(candleChartView: candleChartView) -
//            viewLastCandlePrice.frame.size.height / 2
//
//        if viewLastCandlePriceOffset.constant > candleChartView.frame.size.height - 30 ||
//            viewLastCandlePriceOffset.constant < 5 {
//            viewLastCandlePrice.isHidden = true
//        }
//        else {
//            viewLastCandlePrice.isHidden = false
//        }
    }
    
    func setupUpdatingState() {
        viewEmptyData.isHidden = true
        viewLoadingInfo.isHidden = false
        
        candleChartView.isHidden = true
        barChartView.isHidden = true
        labelChartTopInfo.isHidden = true
        viewLastVisibleCandle.isHidden = true
    }
    
    func setupLoadingState() {
        viewEmptyData.isHidden = true
        viewLoadingInfo.isHidden = false

        headerView.isHidden = true
        candleChartView.isHidden = true
        barChartView.isHidden = true
        labelChartTopInfo.isHidden = true
        viewLastVisibleCandle.isHidden = true
    }
    
    func setupDefaultState() {
        viewLoadingInfo.isHidden = true
        viewEmptyData.isHidden = state.isNotEmpty
        headerView.isHidden = !state.isNotEmpty
        candleChartView.isHidden = !state.isNotEmpty
        barChartView.isHidden = !state.isNotEmpty
        labelChartTopInfo.isHidden = !state.isNotEmpty
        viewLastVisibleCandle.isHidden = !state.isNotEmpty
    }
    
    func setupLocalization() {
        labelLoadingData.text = Localizable.DexChart.Label.loadingChart
        labelEmptyData.text = Localizable.DexChart.Label.emptyData
    }
    
    
}

//MARK: - DexChartHeaderViewDelegate
extension DexChartViewController: DexChartHeaderViewDelegate {
    
    func dexChartDidChangeTimeFrame(_ timeFrame: DexChart.DTO.TimeFrameType) {
        
        candleChartView.clear()
        barChartView.clear()
        
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
        
        setupCandleChartInfo()
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        
        if chartView == barChartView {
            candleChartView.highlightValue(nil)
        }
        else {
            barChartView.highlightValue(nil)
        }
        
        setupCandleChartInfo()
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
        
        setupLastVisibleCandle()
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        setupLastVisibleCandle()
        
        if chartView == candleChartView {
            barChartView.moveViewToX(candleChartView.lowestVisibleX)
        }
        else {
            candleChartView.moveViewToX(barChartView.lowestVisibleX)
        }
        
        if state.candles.count > DexChartHelper.minCountCandlesToZoom {
            
            let value = round(candleChartView.lowestVisibleX)
            
            if let candle = state.candles.first {
                
                if value == candle.timestamp && !state.isPreloading {
                    sendEvent.accept(.preloading(candleLowestVisibleX: candleChartView.lowestVisibleX))
                    
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

    func setupLastVisibleCandle() {
        
        let (position, color, text) = chartHelper.lastVisibleCandleInfo(candleChartView: candleChartView)
        viewLastVisibleCandle.setup(textPrice: text, color: color)
        viewLastVisibleCandleOffset.constant = position - viewLastVisibleCandle.frame.size.height / 2        
    }
    
    func setupCharts() {
        candleChartView.delegate = self
        barChartView.delegate = self
        chartHelper.setupChartStyle(candleChartView: candleChartView, barChartView: barChartView)
    }
    
    func setupCandleChartInfo() {
        
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
   
    func setupChartData(state: DexChart.State) {
        
        
        self.chartHelper.setupChartData(candleChartView: self.candleChartView, barChartView: self.barChartView,
                                        timeFrame: state.timeFrame,
                                        candles: state.candles)
   
       
        if state.action == .changeZoomAfterPreload {
            chartHelper.zoom(candleChartView: candleChartView, barChartView: barChartView,
                                        candles: state.candles,
                                        lowestVisibleX: state.candleLowestVisibleX)
        }
        else {
            chartHelper.setupInitialZoom(candleChartView: candleChartView, barChartView: barChartView, candles: state.candles)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.setupLastVisibleCandle()
        }
    }
}
