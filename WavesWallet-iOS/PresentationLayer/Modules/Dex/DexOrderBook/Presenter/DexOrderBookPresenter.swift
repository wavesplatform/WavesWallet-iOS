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

    var priceAsset: DomainLayer.DTO.Dex.Asset!
    var amountAsset: DomainLayer.DTO.Dex.Asset!
    
    func system(feedbacks: [DexOrderBookPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexOrderBook.State.initialState,
                      reduce: { [weak self] state, event -> DexOrderBook.State in

                        guard let self = self else { return state }

                        return self.reduce(state: state, event: event) },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        
       
        return react(request: { state -> Bool? in
            return state.isNeedRefreshing ? true : nil
            
        }, effects: { [weak self] ss -> Signal<DexOrderBook.Event> in

            guard let self = self else { return Signal.empty() }

            return self.interactor.displayInfo().map {.setDisplayData($0)}.asSignal(onErrorSignalWith: Signal.empty())
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
            
        case .setDisplayData(let data):
            
            if data.authWalletError {
                return state.mutate {
                    $0.isNeedRefreshing = false
                    $0.action = .none
                }
            }
            
            return state.mutate {
                
                let displayData = data.data
                
                $0.isNeedRefreshing = false
                $0.availableAmountAssetBalance = displayData.availableAmountAssetBalance
                $0.availablePriceAssetBalance = displayData.availablePriceAssetBalance
                $0.availableWavesBalance = displayData.availableWavesBalance
                $0.scriptedAssets = displayData.scriptedAssets
                
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
            
        case .didTapBid(let bid, let inputMaxSum):
            
            if !inputMaxSum {
                AnalyticManager.trackEvent(.dex(.sellTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))
            }
            
            moduleOutput?.didCreateOrder(bid, amountAsset: amountAsset, priceAsset: priceAsset,
                                         ask: state.lastAsk?.price,
                                         bid: state.lastBid?.price,
                                         last: state.lastPrice?.price,
                                         availableAmountAssetBalance: state.availableAmountAssetBalance,
                                         availablePriceAssetBalance: state.availablePriceAssetBalance,
                                         availableWavesBalance: state.availableWavesBalance,
                                         inputMaxSum: inputMaxSum,
                                         scriptedAssets: state.scriptedAssets)

            return state.changeAction(.none)
            
        case .didTapEmptyBid:
            AnalyticManager.trackEvent(.dex(.sellTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))

            moduleOutput?.didCreateEmptyOrder(amountAsset: amountAsset, priceAsset: priceAsset,
                                              orderType: .sell,
                                              ask: state.lastAsk?.price,
                                              bid: state.lastBid?.price,
                                              last: state.lastPrice?.price,
                                              availableAmountAssetBalance: state.availableAmountAssetBalance,
                                              availablePriceAssetBalance: state.availablePriceAssetBalance,
                                              availableWavesBalance: state.availableWavesBalance,
                                              scriptedAssets: state.scriptedAssets)
         
            return state.changeAction(.none)
            
        case .didTapAsk(let ask, let inputMaxSum):
            
            if !inputMaxSum {
                AnalyticManager.trackEvent(.dex(.buyTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))
            }

            moduleOutput?.didCreateOrder(ask, amountAsset: amountAsset, priceAsset: priceAsset,
                                         ask: state.lastAsk?.price,
                                         bid: state.lastBid?.price,
                                         last: state.lastPrice?.price,
                                         availableAmountAssetBalance: state.availableAmountAssetBalance,
                                         availablePriceAssetBalance: state.availablePriceAssetBalance,
                                         availableWavesBalance: state.availableWavesBalance,
                                         inputMaxSum: inputMaxSum,
                                         scriptedAssets: state.scriptedAssets)

            return state.changeAction(.none)
            
        case .didTamEmptyAsk:
            AnalyticManager.trackEvent(.dex(.buyTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))

            moduleOutput?.didCreateEmptyOrder(amountAsset: amountAsset, priceAsset: priceAsset,
                                              orderType: .buy,
                                              ask: state.lastAsk?.price,
                                              bid: state.lastBid?.price,
                                              last: state.lastPrice?.price,
                                              availableAmountAssetBalance: state.availableAmountAssetBalance,
                                              availablePriceAssetBalance: state.availablePriceAssetBalance,
                                              availableWavesBalance: state.availableWavesBalance,
                                              scriptedAssets: state.scriptedAssets)

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
