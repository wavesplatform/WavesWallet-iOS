//
//  DexChartPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa


final class DexChartPresenter: DexChartPresenterProtocol {
    
    var interactor: DexChartInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    func system(feedbacks: [DexChartPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexChart.State.initialState,
                      reduce: { [weak self] state, event -> DexChart.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
      
        return react(query: { state -> DexChart.State? in
            
            return state.isNeedLoadingData ? state : nil
            
        }, effects: { [weak self] state -> Signal<DexChart.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }
            
            return strongSelf.interactor.candles(timeFrame: state.timeFrame,
                                                 timeStart: state.timeStart,
                                                 timeEnd: state.timeEnd)
                .map {.setCandles($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexChart.State, event: DexChart.Event) -> DexChart.State {
     
        switch event {
        case .readyView:
            return state.mutate {
                $0.isNeedLoadingData = true
            }.changeAction(.none)
            
        case .refresh:
            return state.mutate {
                $0.isNeedLoadingData = true
                $0.isPreloading = false
                $0.isChangedTimeFrame = false
                $0.candles.removeAll()
                $0.timeEnd = DexChart.State.initialDateTo()
                
            }.changeAction(.none)
            
        case .didChangeTimeFrame(let timeFrame):
            return state.mutate {
                $0.isNeedLoadingData = true
                $0.isPreloading = false
                $0.isChangedTimeFrame = true
                $0.timeFrame = timeFrame
                $0.candles.removeAll()
                $0.timeEnd = DexChart.State.initialDateTo()
                $0.timeStart = DexChart.State.additionalDate(start:$0.timeEnd, timeFrame: timeFrame)
                
            }.changeAction(.changeTimeFrame)
        
        case .preloading:
            return state.mutate {
                $0.isNeedLoadingData = true
                $0.isPreloading = true
                $0.isChangedTimeFrame = false
                $0.timeEnd = $0.timeStart
                $0.timeStart = DexChart.State.additionalDate(start: $0.timeStart, timeFrame: state.timeFrame)
                
                }.changeAction(.none)
            
        case .setCandles(let candles):
            return state.mutate {
                $0.isNeedLoadingData = false
                $0.isPreloading = false
                
                $0.candles.insert(contentsOf: candles, at: 0)
                $0.candles.sort(by: {$0.timestamp < $1.timestamp})
                
                if state.isPreloading {
                    $0.action = .zoomAfterPreloading
                }
                else if state.isChangedTimeFrame {
                    $0.isChangedTimeFrame = false
                    $0.action = .zoomAfterTimeFrameChanged
                }
                else {
                    $0.action = .update
                }
            }
        }
    }
}

fileprivate extension DexChart.State {
    
    func changeAction(_ action: DexChart.State.Action) -> DexChart.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
