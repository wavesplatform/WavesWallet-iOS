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

            return strongSelf.interactor.displayInfo(strongSelf.pair).map {.setDisplayData($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexOrderBook.State, event: DexOrderBook.Event) -> DexOrderBook.State {
        
        switch event {
        case .readyView:
            return state.changeAction(.none)
        
        case .setDisplayData(let displayData):
            
            return state.mutate {
                
                let sectionAsks = DexOrderBook.ViewModel.Section(items: displayData.asks.map {
                    DexOrderBook.ViewModel.Row.ask($0)})

                let sectionLastPrice = DexOrderBook.ViewModel.Section(items:
                    [DexOrderBook.ViewModel.Row.lastPrice(displayData.lastPrice)])
                
                let sectionBids = DexOrderBook.ViewModel.Section(items: displayData.bids.map {
                    DexOrderBook.ViewModel.Row.bid($0)})
                
                if sectionAsks.items.count > 0 || sectionBids.items.count > 0 {
                    $0.sections = [sectionAsks, sectionLastPrice, sectionBids]
                }
                else {
                    $0.sections = []
                }
                
                if !state.hasFirstTimeLoad && $0.sections.count > 0 {
                    $0.hasFirstTimeLoad = true
                    $0.action = .scrollTableToCenter
                }
                else {
                    $0.action = .update
                }
            }
            
        case .tapBuyButton:
            return state.changeAction(.none)
        
        case .tapSellButton:
            return state.changeAction(.none)
        }
    }

}


fileprivate extension DexOrderBook.State {
    
    static var initialState: DexOrderBook.State {

        return DexOrderBook.State(action: .none, sections: [], sellTitle: "-", buyTitle: "-", hasFirstTimeLoad: false)
    }
    
    func changeAction(_ action: DexOrderBook.State.Action) -> DexOrderBook.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
