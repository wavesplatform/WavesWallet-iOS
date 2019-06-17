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
import DomainLayer

final class DexListPresenter: DexListPresenterProtocol {

    var interactor: DexListInteractorProtocol!
    weak var moduleOutput: DexListModuleOutput?

    private let disposeBag = DisposeBag()

    func system(feedbacks: [DexListPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        newFeedbacks.append(localModelsQuery())
        
        Driver.system(initialState: DexList.State.initialState,
                      reduce: { [weak self] state, event -> DexList.State in
                        guard let self = self else { return state }
                        return self.reduce(state: state, event: event) },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func localModelsQuery() -> Feedback {
        return react(request: { state -> DexList.State? in
            
            return state.isNeedRefreshing || state.isNeedUpdateSortLevel ? state : nil
        }, effects: { [weak self] _ -> Signal<DexList.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self.interactor
                .localPairs()
                .map { .setLocalDisplayInfo($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func modelsQuery() -> Feedback {
        return react(request: { state -> DexList.State? in

            return (state.isNeedRefreshing || state.isNeedRefreshingBackground) ? state : nil
        }, effects: { [weak self] _ -> Signal<DexList.Event> in
            
            guard let self = self else { return Signal.empty() }
          
            return self.interactor
                .pairs()
                .map { .setDisplayInfo($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    

    private func reduce(state: DexList.State, event: DexList.Event) -> DexList.State {
    
        switch event {
        case .readyView:

            return state.mutate {
                $0.isNeedRefreshing = true
                }.changeAction(.none)
        
        case .updateSortLevel:
            return state.mutate {
                $0.isNeedUpdateSortLevel = true
            }.changeAction(.none)
            
        case .didChangeAssets:
            return state.mutate {
                $0.hasChangeAssets = true
            }.changeAction(.none)
            
        case .viewWillAppear:

            return state.mutate {
                if $0.hasChangeAssets {
                    $0.isNeedRefreshing = true
                }
            }.changeAction(.none)
            
            
        case .setLocalDisplayInfo(let info):
            return state.mutate {
                $0.authWalletError = info.authWalletError

                if state.isNeedUpdateSortLevel {
                    $0.isNeedUpdateSortLevel = false

                    if let modelSection = state.sections.first(where: {$0.isModelSection}),
                        let headerSection = state.sections.first(where: {$0.isHeaderSection}) {
                        
                        let localModels = info.pairs.reduce(into: [String: DomainLayer.DTO.Dex.SmartPair](), {$0[$1.id] = $1})
                    
                        var newModels: [DexList.DTO.Pair] = []
                        for pair in modelSection.items {
                            if var model = pair.model, let localModel = localModels[model.id] {
                                model.sortLevel = localModel.sortLevel
                                newModels.append(model)
                            }
                        }
                        newModels.sort(by: {$0.sortLevel < $1.sortLevel })
                        
                        let rows = newModels.map{ DexList.ViewModel.Row.model($0) }
                        let newSection = DexList.ViewModel.Section(items: rows)

                        $0.sections = [headerSection, newSection]
                    }
                }
                else {
                    if info.pairs.count > 0 {
                        var rows: [DexList.ViewModel.Row] = []
                        for _ in 0..<info.pairs.count {
                            rows.append(.skeleton)
                        }
                        $0.sections = [DexList.ViewModel.Section(items: rows)]
                    }
                    else {
                        $0.sections = []
                    }
                }

            }.changeAction(.update)
            
        case .setDisplayInfo(let response):
            
            switch response.result {
            
            case .success(let data):
                
                let models = data.pairs
                
                return state.mutate { state in
                    
                    state.authWalletError = data.authWalletError
                    state.isFirstLoadingData = false
                    state.isNeedRefreshing = false
                    state.hasChangeAssets = false
                    state.isNeedRefreshingBackground = false
                    state.isNeedUpdateSortLevel = false

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
                    $0.authWalletError = false
                    $0.isNeedRefreshing = false
                    $0.action = .didFailGetModels(error)
                    $0.hasChangeAssets = false
                    $0.isNeedRefreshingBackground = false
                    $0.isNeedUpdateSortLevel = false
                }
            }
           
        case .tapSortButton(let delegate):
            moduleOutput?.showDexSort(delegate: delegate)
            return state.changeAction(.none)

        case .tapAddButton(let delegate):
            moduleOutput?.showAddList(delegate: delegate)
            return state.changeAction(.none)
            
        case .refreshBackground:
            return state.mutate {
                $0.isNeedRefreshingBackground = true
            }.changeAction(.none)
            
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
        return DexList.State(isNeedRefreshing: false,
                             isNeedRefreshingBackground: false,
                             isNeedUpdateSortLevel: false,
                             action: .none,
                             sections: [],
                             isFirstLoadingData: true,
                             lastUpdate: Date(),
                             errorState: .none,
                             authWalletError: false,
                             hasChangeAssets: false)
    }
    
    func changeAction(_ action: DexList.State.Action) -> DexList.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
