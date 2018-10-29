//
//  DexDataContainer.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa


final class DexListPresenter: DexListPresenterProtocol {

    var interactor: DexListInteractorProtocol!
    weak var moduleOutput: DexListModuleOutput?

    private let disposeBag = DisposeBag()

    func system(feedbacks: [DexListPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexList.State.initialState,
                      reduce: { [weak self] state, event -> DexList.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        return react(query: { state -> Bool? in

            return state.isNeedRefreshing == true ? true : nil
        }, effects: { [weak self] _ -> Signal<DexList.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.pairs().map { .setModels($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    

    private func reduce(state: DexList.State, event: DexList.Event) -> DexList.State {
    
        switch event {
        case .readyView:
            return state.mutate {
                $0.isNeedRefreshing = true
                }.changeAction(.update)
            
        case .setModels(let models):
            
            return state.mutate { state in
                
                state.isNeedRefreshing = false
                state.isFirstLoadingData = false
                
                if models.count > 0 {
                    
                    let rowHeader =  DexList.ViewModel.Row.header(Date())
                    let sectionHeader = DexList.ViewModel.Section(items: [rowHeader])
                    
                    let items = models.map { DexList.ViewModel.Row.model($0) }
                    let itemsSection = DexList.ViewModel.Section(items: items)
                    
                    state.sections = [sectionHeader, itemsSection]
                }
                else {
                    state.sections = []
                }
                
                }.changeAction(.update)
            
        case .tapSortButton:
            moduleOutput?.showDexSort()
            return state.changeAction(.none)

        case .tapAddButton:
            moduleOutput?.showAddList()
            return state.changeAction(.none)
            
        case .refresh:
            interactor.refreshPairs()
            return state.mutate { $0.isNeedRefreshing = true }.changeAction(.none)
        
        case .tapAssetPair(let pair):

            let tradePair = DexTraderContainer.DTO.Pair(amountAsset: pair.amountAsset, priceAsset: pair.priceAsset, isHidden: pair.isHidden)
            moduleOutput?.showTradePairInfo(pair: tradePair)
            
            return state.changeAction(.none)
        }
    }
  
}

fileprivate extension DexList.State {
    static var initialState: DexList.State {
        let section = DexList.ViewModel.Section(items: [.skeleton, .skeleton, .skeleton, .skeleton])
        return DexList.State(isNeedRefreshing: false, action: .none, sections: [section], isFirstLoadingData: true, lastUpdate: Date())
    }
    
    func changeAction(_ action: DexList.State.Action) -> DexList.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
