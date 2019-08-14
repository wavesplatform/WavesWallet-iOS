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
import Extensions


private typealias Types = AssetsSearch

final class AssetsSearchSystem: System<AssetsSearch.State, AssetsSearch.Event> {
    
    private let assetsRepository: AssetsRepositoryProtocol = UseCasesFactory.instance.repositories.assetsRepositoryRemote
    
    private let assets: [DomainLayer.DTO.Asset]
    private let maxSelectAssets: Int
    private let minSelectAssets: Int
    
    
    init(assets: [DomainLayer.DTO.Asset], minCountAssets: Int, maxCountAssets: Int) {
        self.assets = assets
        self.minSelectAssets = minCountAssets
        self.maxSelectAssets = maxCountAssets
    }
    
    override func initialState() -> State! {
        
        return AssetsSearch.State(ui: uiState(assets: self.assets), core: coreState(assets: self.assets))
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
                                         selectedAssets: state.core.selectAssets,
                                         minSelectAssets: minSelectAssets,
                                         maxSelectAssets: state.core.maxSelectAssets)
            state.core.assets = assets
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
            
            let currentCount = state.core.selectAssets.count
            let isSelect = state.core.selectAssets[asset.id] != nil
            let isLockForSelect = currentCount == state.core.maxSelectAssets
            let isLockForUnselect = currentCount == minSelectAssets
            
            if isSelect == false && isLockForSelect {
                return
            }
            
            if isSelect == true && isLockForUnselect {
                return
            }
                                   
            if isSelect {
                state.core.selectAssets.removeValue(forKey: asset.id)
            } else {
                state.core.selectAssets[asset.id] = asset
            }
            
            state
                .ui[indexPath] = .asset(AssetsSearchAssetCell.Model(asset: asset,
                                                                    state: isSelect == true ? .unselected : .selected ))
            
            state.core.action = .selected(state.core.selectAssets.map { $0.value })
            
            state.ui.countSelectedAssets = state.core.selectAssets.count
            state.ui.action = .update
        
            
            let countAfterUpdate = state.core.selectAssets.count
            
            let isLockedAfterUpdate = countAfterUpdate == state.core.maxSelectAssets || countAfterUpdate == minSelectAssets
            
            if isLockedAfterUpdate != isLockForSelect  {
                state.ui.sections = sections(assets: state.core.assets,
                                             selectedAssets: state.core.selectAssets,
                                             minSelectAssets: minSelectAssets,
                                             maxSelectAssets: state.core.maxSelectAssets)
            }
        
        default:
            break
        }
    }
    
    private func uiState(assets: [DomainLayer.DTO.Asset]) -> State.UI! {
        
        let selectedAssets = assets.reduce(into: [String: DomainLayer.DTO.Asset](), { $0[$1.id] = $1 })
        
        return AssetsSearch.State.UI(sections: sections(assets: [],
                                                        selectedAssets: selectedAssets,
                                                        minSelectAssets: minSelectAssets,
                                                        maxSelectAssets: maxSelectAssets),
                                     action: .update,
                                     maxSelectAssets: maxSelectAssets,
                                     countSelectedAssets: assets.count)
    }
    
    private func coreState(assets: [DomainLayer.DTO.Asset]) -> State.Core! {
        
        let selectAssets = assets.reduce(into: [String: DomainLayer.DTO.Asset].init()) { (result, asset) in
            result[asset.id] = asset
        }
        
        return AssetsSearch.State.Core(action: .none,
                                       assets: assets,
                                       selectAssets: selectAssets,
                                       minSelectAssets: self.minSelectAssets,
                                       maxSelectAssets: self.maxSelectAssets)
    }
    
    private func sections(assets: [DomainLayer.DTO.Asset],
                          selectedAssets: [String: DomainLayer.DTO.Asset],
                          minSelectAssets: Int,
                          maxSelectAssets: Int) -> [Types.Section] {
        
        let isLocked = selectedAssets.count == maxSelectAssets
        
        let rows = assets.map { (asset) -> Types.Row in
            let isSelected = selectedAssets[asset.id] != nil
            
            var state: AssetsSearchAssetCell.Model.State = .unselected
            
            if isSelected {
                state = .selected
            } else {
                if isLocked {
                    state = .lock
                } else {
                    state = .unselected
                }
            }
            
            return Types.Row.asset(AssetsSearchAssetCell.Model(asset: asset, state: state))
        }
        
        return [Types.Section(rows: rows)]
    }
}

