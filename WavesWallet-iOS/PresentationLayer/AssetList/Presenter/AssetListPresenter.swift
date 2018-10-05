//
//  AssetListPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

final class AssetListPresenter: AssetListPresenterProtocol {
    
    var interactor: AssetListInteractorProtocol!
    var filters: [AssetList.DTO.Filter] = []
    
    weak var moduleOutput: AssetListModuleOutput?
    
    private let disposeBag = DisposeBag()
    
    func system(feedbacks: [AssetListPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: AssetList.State.initialState,
                      reduce: { [weak self] state, event -> AssetList.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return state.isAppeared ? true : nil
        }, effects: { [weak self] _ -> Signal<AssetList.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.assets(filters: strongSelf.filters).map {.setAssets($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: AssetList.State, event: AssetList.Event) -> AssetList.State {
       
        switch event {
        case .readyView:
            return state.mutate {
                $0.isAppeared = true
            }.changeAction(.none)
            
        case .setAssets(let assets):
            return state.mutate {
                
                let items = assets.map { AssetList.ViewModel.Row.asset($0) }
                let section = AssetList.ViewModel.Section(items: items)
                $0.section = section
                
            }.changeAction(.update)
            
        case .searchTextChange(let text):
                interactor.searchAssets(searchText: text)
            return state.changeAction(.none)
            
        case .didSelectAsset(let asset):
                moduleOutput?.assetListDidSelectAsset(asset)
            return state.changeAction(.none)
        }
    }
}

fileprivate extension AssetList.State {
    
    static var initialState: AssetList.State {
        let section = AssetList.ViewModel.Section(items: [])
        return AssetList.State(isAppeared: false, action: .none, section: section)
    }
    
    func changeAction(_ action: AssetList.State.Action) -> AssetList.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
