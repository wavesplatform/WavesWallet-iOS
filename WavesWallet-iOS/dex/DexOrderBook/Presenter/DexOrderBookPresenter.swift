//
//  DexOrderBookPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa



final class DexOrderBookPresenter: DexOrderBookPresenterProtocol {

    var interactor: DexOrderBookInteractorProtocol!
    private let disposeBag = DisposeBag()

//    weak var moduleOutput: DexMarketModuleOutput?

    var pair: DexTraderContainer.DTO.Pair!
 
    func system(feedbacks: [DexOrderBookPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexOrderBook.State.initialState,
                      reduce: reduce,
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        
       
        return react(query: { state -> Bool? in
            return true
        }, effects: { [weak self] ss -> Signal<DexOrderBook.Event> in

            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            

            
            return strongSelf.interactor.bidsAsks(strongSelf.pair).map {.setBids($0.bids)}.asSignal(onErrorSignalWith: Signal.empty())

//            return strongSelf.interactor.pairs().map { .setPairs($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexOrderBook.State, event: DexOrderBook.Event) -> DexOrderBook.State {
        
        return state
        
    }

}


fileprivate extension DexOrderBook.State {
    static var initialState: DexOrderBook.State {

        return DexOrderBook.State(action: .none)
    }
    
    func changeAction(_ action: DexOrderBook.State.Action) -> DexOrderBook.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
