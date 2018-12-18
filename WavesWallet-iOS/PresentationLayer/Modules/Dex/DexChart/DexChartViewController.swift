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
    
    @IBOutlet private weak var viewLastVisibleCandleOffset: NSLayoutConstraint!
    @IBOutlet weak var viewLastVisibleCandle: DexChartCandlePriceView!
    
    @IBOutlet private weak var viewHighlightedCandle: DexChartCandlePriceView!
    @IBOutlet private weak var viewHighlightedCandleOffset: NSLayoutConstraint!
    
    private var chartHelper = DexChartHelper()
    private var state = DexChart.State.initialState
    private let sendEvent: PublishRelay<DexChart.Event> = PublishRelay<DexChart.Event>()
    private var lowestVisibleX: Double = 0
    private var candles: [DomainLayer.DTO.Candle] = []
    
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
            return Bindings(subscriptions: owner.subscriptions(state: state), mutations: owner.events())
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
                strongSelf.state = state
                guard state.action != .none else { return }
                
                strongSelf.candles = state.candles
                strongSelf.headerView.setupTimeFrame(timeFrame: state.timeFrame)
                strongSelf.headerView.stopAnimation()
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
        labelLoadingData.text = Localizable.Waves.Dexchart.Label.loadingChart
        labelEmptyData.text = Localizable.Waves.Dexchart.Label.emptyData
    }
}

//MARK: - DexChartHeaderViewDelegate
extension DexChartViewController: DexChartHeaderViewDelegate {
    
    func dexChartDidTapRefresh() {
        sendEvent.accept(.refresh)
    }
    
    func dexChartDidChangeTimeFrame(_ timeFrame: DomainLayer.DTO.Candle.TimeFrameType) {
        
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
        updateHighlightedPosition()
        
        lowestVisibleX = candleChartView.lowestVisibleX
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
        setupLastVisibleCandle()
        updateHighlightedPosition()
        
        if chartView == candleChartView {
            barChartView.moveViewToX(candleChartView.lowestVisibleX)
        }
        else {
            candleChartView.moveViewToX(barChartView.lowestVisibleX)
        }
        
        lowestVisibleX = candleChartView.lowestVisibleX
        
        if candles.count > DexChartHelper.minCountCandlesToZoom {

            let value = round(candleChartView.lowestVisibleX)
            let candle = candles[0]
            if value == candle.timestamp && !state.isPreloading {
                sendEvent.accept(.preloading)
            }
        }
    }
}


//MARK: - Setup Charts
private extension DexChartViewController {

    func setupLastVisibleCandle() {
        
        let (position, color, price) = chartHelper.lastVisibleCandleInfo(candleChartView: candleChartView)
        viewLastVisibleCandle.setup(price: price, color: color, pair: pair)
        viewLastVisibleCandleOffset.constant = position - viewLastVisibleCandle.frame.size.height / 2
    }
    
    func setupCharts() {
        candleChartView.delegate = self
        barChartView.delegate = self
        chartHelper.setupChartStyle(candleChartView: candleChartView, barChartView: barChartView, pair: pair)
        viewHighlightedCandle.highlightedMode = true
        viewHighlightedCandle.isHidden = true
    }
    
    func updateHighlightedPosition() {
        if candleChartView.highlighted.count > 0 {
            let (positionY, _, _) = chartHelper.highlightedCandleInfo(candleChartView: candleChartView,
                                                                      highlightedView: viewHighlightedCandle,
                                                                      state: state)
            viewHighlightedCandleOffset.constant = positionY
        }
    }
    
    
    func setupCandleChartInfo() {
        
        let title = pair.amountAsset.name + " / " + pair.priceAsset.name
        
        let isVisibleHighlight = candleChartView.highlighted.count > 0
        
        viewHighlightedCandle.isHidden = !isVisibleHighlight
        
        if isVisibleHighlight {
            
            let (positionY, topTitle, price) = chartHelper.highlightedCandleInfo(candleChartView: candleChartView,
                                                                         highlightedView:viewHighlightedCandle,
                                                                         state: state)
            
            labelChartTopInfo.text = title + ", " + topTitle

            viewHighlightedCandle.setup(price: price, color: UIColor.basic700, pair: pair)
            viewHighlightedCandleOffset.constant = positionY
        }
        else {
            labelChartTopInfo.text = title + ", " + state.timeFrame.shortText
        }
    }
   
    func setupChartData(state: DexChart.State) {
        
        chartHelper.setupChartData(candleChartView: candleChartView, barChartView: barChartView,
                                   timeFrame: state.timeFrame,
                                   candles: candles,
                                   pair: pair)

        if state.action == .zoomAfterPreloading {
            chartHelper.zoom(candleChartView: candleChartView, barChartView: barChartView,
                             candles: candles,
                             lowestVisibleX: lowestVisibleX)
        }
        else if state.action == .zoomAfterTimeFrameChanged {
            chartHelper.updateAfterTimeFrameChanged(candleChartView: candleChartView, barChartView: barChartView, candles: candles)
        }
        else {
            chartHelper.setupInitialZoom(candleChartView: candleChartView, barChartView: barChartView, candles: candles)
        }
        viewLastVisibleCandle.setupWidth(candles: candles, pair: pair)
        viewHighlightedCandle.setupWidth(candles: candles, pair: pair)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.setupLastVisibleCandle()
        }
    }
}
