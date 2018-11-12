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
    weak var moduleOutput: DexOrderBookModuleOutput?
    
    private let disposeBag = DisposeBag()

    var priceAsset: Dex.DTO.Asset!
    var amountAsset: Dex.DTO.Asset!
    
    func system(feedbacks: [DexOrderBookPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexOrderBook.State.initialState,
                      reduce: { [weak self] state, event -> DexOrderBook.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        
       
        return react(query: { state -> Bool? in
            return state.isNeedRefreshing ? true : nil
            
        }, effects: { [weak self] ss -> Signal<DexOrderBook.Event> in

            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.interactor.displayInfo().map {.setDisplayData($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexOrderBook.State, event: DexOrderBook.Event) -> DexOrderBook.State {
        
        switch event {
        case .readyView:
            return state.mutate {
                $0.isNeedRefreshing = true
            }.changeAction(.none)
            
        case .updateData:
            return state.mutate {
                $0.isNeedRefreshing = true
            }.changeAction(.none)
            
        case .setDisplayData(let displayData):
            
            return state.mutate {
                
                $0.isNeedRefreshing = false
                $0.availableAmountAssetBalance = displayData.availableAmountAssetBalance
                $0.availablePriceAssetBalance = displayData.availablePriceAssetBalance
                $0.availableWavesBalance = displayData.availableWavesBalance
                
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
                
                $0.header = displayData.header
                
                if !state.hasFirstTimeLoad {
                    $0.hasFirstTimeLoad = true
                    $0.action = $0.sections.count > 0 ? .scrollTableToCenter : .update
                }
                else {
                    $0.action = .update
                }
            }
            
        case .didTapBid(let bid):
            
            moduleOutput?.didCreateOrder(bid, amountAsset: amountAsset, priceAsset: priceAsset,
                                         ask: state.lastAsk?.price,
                                         bid: state.lastBid?.price,
                                         last: state.lastPrice?.price,
                                         availableAmountAssetBalance: state.availableAmountAssetBalance,
                                         availablePriceAssetBalance: state.availablePriceAssetBalance,
                                         availableWavesBalance: state.availableWavesBalance)
            return state.changeAction(.none)
            
        case .didTapEmptyBid:
            moduleOutput?.didCreateEmptyOrder(amountAsset: amountAsset, priceAsset: priceAsset,
                                              orderType: .sell,
                                              ask: state.lastAsk?.price,
                                              bid: state.lastBid?.price,
                                              last: state.lastPrice?.price,
                                              availableAmountAssetBalance: state.availableAmountAssetBalance,
                                              availablePriceAssetBalance: state.availablePriceAssetBalance,
                                              availableWavesBalance: state.availableWavesBalance)
            return state.changeAction(.none)
            
        case .didTapAsk(let ask):
            moduleOutput?.didCreateOrder(ask, amountAsset: amountAsset, priceAsset: priceAsset,
                                         ask: state.lastAsk?.price,
                                         bid: state.lastBid?.price,
                                         last: state.lastPrice?.price,
                                         availableAmountAssetBalance: state.availableAmountAssetBalance,
                                         availablePriceAssetBalance: state.availablePriceAssetBalance,
                                         availableWavesBalance: state.availableWavesBalance)
            return state.changeAction(.none)
            
        case .didTamEmptyAsk:
            
            moduleOutput?.didCreateEmptyOrder(amountAsset: amountAsset, priceAsset: priceAsset,
                                              orderType: .buy,
                                              ask: state.lastAsk?.price,
                                              bid: state.lastBid?.price,
                                              last: state.lastPrice?.price,
                                              availableAmountAssetBalance: state.availableAmountAssetBalance,
                                              availablePriceAssetBalance: state.availablePriceAssetBalance,
                                              availableWavesBalance: state.availableWavesBalance)
            return state.changeAction(.none)
        }
    }

}


fileprivate extension DexOrderBook.State {
    
    func changeAction(_ action: DexOrderBook.State.Action) -> DexOrderBook.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
