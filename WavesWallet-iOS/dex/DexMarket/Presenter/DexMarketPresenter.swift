//
//  DexMarketPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa


final class DexMarketPresenter: DexMarketPresenterProtocol {
 
    var interactor: DexMarketInteractorProtocol!
    weak var moduleOutput: DexMarketModuleOutput?

    private let disposeBag = DisposeBag()

    func system(feedbacks: [DexMarketPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        newFeedbacks.append(searchModelsQuery())

        Driver.system(initialState: DexMarket.State.initialState,
                      reduce: reduce,
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return true
        }, effects: { [weak self] _ -> Signal<DexMarket.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.pairs().map { .setPairs($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func searchModelsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return true
        }, effects: { [weak self] _ -> Signal<DexMarket.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.searchPairs().map { .setPairs($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexMarket.State, event: DexMarket.Event) -> DexMarket.State {
        
        switch event {
        case .readyView:
            return state.changeAction(.none)
        case .setPairs(let pairs):
            
            return state.mutate { state in
                
                let items = pairs.map { DexMarket.ViewModel.Row.pair($0) }
                let section = DexMarket.ViewModel.Section(items: items)
                state.section = section
                
            }.changeAction(.update)
        
        case .tapCheckMark(let index):
            
            if let pair = state.section.items[index].pair {
                interactor.checkMark(pair: pair)
            }
            
            return state.mutate { state in
                if let pair = state.section.items[index].pair {
                    state.section.items[index] = DexMarket.ViewModel.Row.pair(pair.mutate {$0.isChecked = !$0.isChecked})
                }
            }.changeAction(.update)
            
        case .tapInfoButton(let index):
            
            if let pair = state.section.items[index].pair {
                
                let infoPair = DexInfoPair.DTO.Pair(amountAsset: pair.amountAsset.id, amountAssetName: pair.amountAsset.name, priceAsset: pair.priceAsset.id, priceAssetName: pair.priceAsset.name, isPopular: !pair.isHiddenPair)
                moduleOutput?.showInfo(pair: infoPair)
            }
            return state.changeAction(.none)
            
        case .searchTextChange(let text):
            
            interactor.searchPair(searchText: text)
            return state.changeAction(.none)
        }
    }
}

fileprivate extension DexMarket.ViewModel.Row {
    
    var pair: DexMarket.DTO.AssetPair? {
        switch self {
        case .pair(let pair):
            return pair
        }
    }
}

fileprivate extension DexMarket.State {
    static var initialState: DexMarket.State {
        let section = DexMarket.ViewModel.Section(items: [])
        return DexMarket.State(action: .update, section: section)
    }
    
    func changeAction(_ action: DexMarket.State.Action) -> DexMarket.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
