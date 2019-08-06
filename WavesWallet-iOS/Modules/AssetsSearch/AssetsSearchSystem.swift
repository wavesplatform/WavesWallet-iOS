//
//  AssetsSearchSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxFeedback
import RxSwift
import RxCocoa

//TODO: Waves logo не парвильно
//TODO: Spam лист

private typealias Types = AssetsSearch

final class AssetsSearchSystem: System<AssetsSearch.State, AssetsSearch.Event> {
    
    private let assetsRepository: AssetsRepositoryProtocol = UseCasesFactory.instance.repositories.assetsRepositoryRemote
    
    override func initialState() -> State! {
        
        return AssetsSearch.State(ui: uiState(), core: coreState())
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [searchAsset()]
    }
    
    private func searchAsset() -> Feedback {
        
        return react(request: { (state) -> String? in
            
            if case .search(let text) = state.core.action {
                return text
            }

            return nil
            
        }, effects: { [weak self] (search) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
            
            return Signal<Int>.timer(0.25, period: 1)
                .flatMap({ [weak self] _ -> Signal<Event> in
                    guard let self = self else { return Signal.never() }
                    return self.assetsRepository
                        .searchAssets(search: search)
                        .map { $0.count > 0 ? Event.assets($0) : Event.empty }
                        .asSignal(onErrorRecover: { _ -> Signal<Event> in
                            return Signal.just(Event.empty)
                        })
                })
        })
    }

    override func reduce(event: Event, state: inout State) {
        
        switch event {

        case .empty:
            
            state.ui.sections = [Types.Section(rows: [.empty])]
            state.ui.action = .update
            state.core.action = .none
        
        case .assets(let assets):
            
            state.ui.sections = sections(assets: assets,
                                        selectedAssets: state.core.selectAssets)
            state.core.action = .none
            state.ui.action = .update
            
        case .search(let string):
            
            if string.isEmpty {
                state.ui.sections = []
                state.ui.action = .update
                state.core.action = .none
            } else {
                state.core.action = .search(string)
                state.ui.action = .loading
            }
            
        case .select(let indexPath):
            let row = state.ui[indexPath]
            guard let asset = row.asset else { return }
            
            let isSelect = state.core.selectAssets[asset.id] != nil
            
            if isSelect {
                state.core.selectAssets[asset.id] = nil
            } else {
                state.core.selectAssets[asset.id] = asset
            }
            
            state
                .ui[indexPath] = .asset(AssetsSearchAssetCell.Model(asset: asset,
                                                                    isSelected: !isSelect))
            
            state.ui.action = .update
            state.core.action = .selected(state.core.selectAssets.map { $0.value })
        
        default:
            break
        }
    }
    
    private func uiState() -> State.UI! {
        return AssetsSearch.State.UI(sections: sections(assets: [], selectedAssets: .init()), action: .update)
    }
    
    private func coreState() -> State.Core! {
        return AssetsSearch.State.Core(action: .none, selectAssets: .init())
    }
    
    private func sections(assets: [DomainLayer.DTO.Asset], selectedAssets: [String: DomainLayer.DTO.Asset]) -> [Types.Section] {
        
        let rows = assets.map { (asset) -> Types.Row in
            let isSelected = selectedAssets[asset.id] != nil
            return Types.Row.asset(AssetsSearchAssetCell.Model(asset: asset, isSelected: isSelected))
        }
        
        return [Types.Section(rows: rows)]
    }
}

