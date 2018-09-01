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
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            
            return strongSelf.interactor.candles(timeFrame: state.timeFrame,
                                                 dateFrom: state.dateFrom,
                                                 dateTo: state.dateTo)
                .map {.setCandles($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexChart.State, event: DexChart.Event) -> DexChart.State {
     
        switch event {
        case .readyView:
            return state.mutate {
                $0.isNeedLoadingData = true
            }.changeAction(.none)
            
        case .didChangeTimeFrame(let timeFrame):
            return state.mutate {
                $0.isNeedLoadingData = true 
                $0.timeFrame = timeFrame
                $0.candles = []
                 
            }.changeAction(.update)
            
        case .setCandles(let candles):
            return state.mutate {
                $0.isNeedLoadingData = false

                $0.candles.append(contentsOf: candles)
                $0.candles.sort(by: {$0.timestamp < $1.timestamp})
                
                //        candles.sort(using: [NSSortDescriptor.init(key: "timestamp", ascending: true)])
            }.changeAction(.update)
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
