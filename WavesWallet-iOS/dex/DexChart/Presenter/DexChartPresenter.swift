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
    
    private var state = DexChart.State.initialState
    
    func system(feedbacks: [DexChartPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexChart.State.initialState,
                      reduce: reduce,
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> Bool? in
            return true
        }, effects: { [weak self] ss -> Signal<DexChart.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            
            let state = strongSelf.state
            
            return strongSelf.interactor.candles(timeFrame: state.timeFrame,
                                                 dateFrom: state.dateFrom,
                                                 dateTo: state.dateTo)
                .map {.setCandles($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexChart.State, event: DexChart.Event) -> DexChart.State {
     
        switch event {
        case .readyView:
            return state.changeAction(.none)
            
        case .didChangeTimeFrame(let timeFrame):
            return state.mutate {
                $0.timeFrame = timeFrame
                $0.candles = []
                self.state = $0
                
            }.changeAction(.update)
            
        case .setCandles(let candles):
            return state.mutate {
                $0.candles.append(contentsOf: candles)
                $0.candles.sort(by: {$0.timestamp < $1.timestamp})                
                self.state = $0
                
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
