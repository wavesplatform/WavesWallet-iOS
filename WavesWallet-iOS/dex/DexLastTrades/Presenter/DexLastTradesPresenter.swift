//
//  DexLastTradesPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

final class DexLastTradesPresenter: DexLastTradesPresenterProtocol {
    
    var interactor: DexLastTradesInteractorProtocol!
    private let disposeBag = DisposeBag()

    weak var moduleOutput: DexLastTradesModuleOutput?
    
    var priceAsset: Dex.DTO.Asset!
    var amountAsset: Dex.DTO.Asset!
    
    func system(feedbacks: [DexLastTradesPresenterProtocol.Feedback]) {
        
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        
        Driver.system(initialState: DexLastTrades.State.initialState,
                      reduce: { [weak self] state, event -> DexLastTrades.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> Bool? in
            return state.isNeedRefreshing ? true : nil
            
        }, effects: { [weak self] ss -> Signal<DexLastTrades.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.displayInfo().map {.setDisplayData($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexLastTrades.State, event: DexLastTrades.Event) -> DexLastTrades.State {
        
        switch event {
        case .readyView:
            return state.mutate {
                $0.isNeedRefreshing = true
            }.changeAction(.none)
            
        case .setDisplayData(let displayData):
            return state.mutate {
                
                $0.isNeedRefreshing = false
                $0.hasFirstTimeLoad = true
                $0.lastBuy = displayData.lastBuy
                $0.lastSell = displayData.lastSell
                
                let items = displayData.trades.map {DexLastTrades.ViewModel.Row.trade($0)}
                $0.section = DexLastTrades.ViewModel.Section(items: items)
            }.changeAction(.update)
        
        case .didTapBuy(let buy):
            
            moduleOutput?.didCreateOrder(buy, priceAsset: priceAsset, amountAsset: amountAsset)
            return state.changeAction(.none)
        
        case .didTapEmptyBuy:
            moduleOutput?.didCreateOrderBuyEmpty(priceAsset: priceAsset, amountAsset: amountAsset)
            return state.changeAction(.none)
            
        case .didTapSell(let sell):
            moduleOutput?.didCreateOrder(sell, priceAsset: priceAsset, amountAsset: amountAsset)
            return state.changeAction(.none)
            
        case .didTapEmptySell:
            moduleOutput?.didCreateOrderSellEmpty(priceAsset: priceAsset, amountAsset: amountAsset)
            return state.changeAction(.none)
        }
       
    }
}

fileprivate extension DexLastTrades.State {
   
    func changeAction(_ action: DexLastTrades.State.Action) -> DexLastTrades.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
