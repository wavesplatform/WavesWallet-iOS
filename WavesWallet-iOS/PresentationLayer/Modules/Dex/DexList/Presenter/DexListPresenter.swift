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
                        guard let self = self else { return state }
                        return self.reduce(state: state, event: event) },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        return react(request: { state -> DexList.State? in

            return (state.isAppear || state.isNeedRefreshing) ? state : nil
        }, effects: { [weak self] _ -> Signal<DexList.Event> in
            
            guard let self = self else { return Signal.empty() }
            return self.interactor
                .pairs()
                .map { .setModels($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    

    private func reduce(state: DexList.State, event: DexList.Event) -> DexList.State {
    
        switch event {
        case .readyView:
            return state.mutate {
                $0.isAppear = true
                }.changeAction(.update)
            
        case .setModels(let response):
            
            switch response.result {
            
            case .success(let models):
                return state.mutate { state in
                    
                    state.isAppear = false
                    state.isFirstLoadingData = false
                    state.isNeedRefreshing = false
                    
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
                
            case .error(let error):
                return state.mutate {
                    $0.isAppear = false
                    $0.isNeedRefreshing = false
                    $0.action = .didFailGetModels(error)
                }
            }
           
            
        case .tapSortButton(let delegate):
            moduleOutput?.showDexSort(delegate: delegate)
            return state.changeAction(.none)

        case .tapAddButton(let delegate):
            moduleOutput?.showAddList(delegate: delegate)
            return state.changeAction(.none)
            
        case .refresh:
            return state.mutate {
                $0.isNeedRefreshing = true
            }.changeAction(.none)
        
        case .tapAssetPair(let pair):

            let tradePair = DexTraderContainer.DTO.Pair(amountAsset: pair.amountAsset, priceAsset: pair.priceAsset, isGeneral: pair.isGeneral)
            moduleOutput?.showTradePairInfo(pair: tradePair)
            
            return state.changeAction(.none)
        }
    }
  
}

fileprivate extension DexList.State {
    static var initialState: DexList.State {
        let section = DexList.ViewModel.Section(items: [.skeleton, .skeleton, .skeleton, .skeleton])
        return DexList.State(isAppear: false,
                             isNeedRefreshing: false,
                             action: .none,
                             sections: [section],
                             isFirstLoadingData: true,
                             lastUpdate: Date(),
                             errorState: .none)
    }
    
    func changeAction(_ action: DexList.State.Action) -> DexList.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
