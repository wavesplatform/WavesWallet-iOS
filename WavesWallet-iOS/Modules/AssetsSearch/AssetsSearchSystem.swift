//
//  AssetsSearchSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import RxFeedback
import RxSwift
import RxCocoa
import Extensions

private enum Constants {
    static let MinersRewardTokenId = "4uK8i4ThRGbehENwa6MxyLtxAjAo1Rj9fduborGExarC"
    static let WavesCommunityTokenId = "DHgwrRvVyqJsepd32YbBqUeDH4GJ1N984X8QoekjgH8J"
}

private typealias Types = AssetsSearch

final class AssetsSearchSystem: System<AssetsSearch.State, AssetsSearch.Event> {
    
    private let assetsRepository: AssetsRepositoryProtocol = UseCasesFactory.instance.repositories.assetsRepositoryRemote
    private let serverEnvironmentUseCase: ServerEnvironmentRepository = UseCasesFactory.instance.serverEnvironmentUseCase
    private let environmentRepository: EnvironmentRepositoryProtocol = UseCasesFactory.instance.repositories.environmentRepository
    
    private let assets: [Asset]
    private let maxSelectAssets: Int
    private let minSelectAssets: Int
    
    
    init(assets: [Asset], minCountAssets: Int, maxCountAssets: Int) {
        self.assets = assets
        self.minSelectAssets = minCountAssets
        self.maxSelectAssets = maxCountAssets
    }
    
    override func initialState() -> State! {
        
        return AssetsSearch.State(ui: uiState(assets: self.assets), core: coreState(assets: self.assets))
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [searchAsset(), initialAssets()]
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
                    
                    return self
                        .serverEnvironmentUseCase
                        .serverEnvironment()
                        .flatMap { [weak self] serverEnviroment -> Observable<[Asset]> in
                            
                            guard let self = self else { return Observable.never() }
                            
                            return self
                                .assetsRepository
                                .searchAssets(serverEnvironment: serverEnviroment,
                                              search: search,
                                              accountAddress: "")
                            
                        }
                        .map { $0.count > 0 ? Event.assets($0) : Event.empty }
                        .asSignal(onErrorRecover: { error -> Signal<Event> in
                            return Signal.just(.handlerError(error))
                        })
                })
        })
    }
    
    private func initialAssets() -> Feedback {
        
        return react(request: { (state) -> Bool? in
            
            if case .initialAssets = state.core.action {
                return true
            }
            
            return nil
            
        }, effects: { [weak self] (search) -> Signal<Event> in
            
            guard let self = self else { return Signal.never() }
                        
            return Observable.zip(self.serverEnvironmentUseCase.serverEnvironment(),
                                  self.environmentRepository.walletEnvironment())
                .flatMap({ [weak self] serverEnviroment, walletEnvironment -> Observable<Event> in
                    
                    guard let self = self else { return Observable.never() }
                    
                    var assetsId = walletEnvironment
                        .generalAssets
                        .map { $0.assetId }
                  
                    assetsId.append(Constants.MinersRewardTokenId)
                    assetsId.append(Constants.WavesCommunityTokenId)
                    
                    return self
                        .assetsRepository
                        .assets(serverEnvironment: serverEnviroment,
                                ids: assetsId,
                                accountAddress: "")
                        .map { $0.count > 0 ? Event.assets($0) : Event.empty }
                })
                .asSignal(onErrorRecover: { error -> Signal<Event> in
                    return Signal.just(.handlerError(error))
                })
        })
    }

    override func reduce(event: Event, state: inout State) {
        
        switch event {
        
        case .viewDidAppear:
            
            guard state.core.isInitial == false else { return }
            state.core.isInitial = true
            state.core.action = .initialAssets
            state.ui.sections = []
            state.ui.action = .loading
            
        case .refresh:
            
            if let action = state.core.invalidAction {
                state.ui.action = .loading
                state.core.action = action
            } else {
                state.ui.action = .none
                state.core.action = .none
            }
            state.core.invalidAction = nil
            
        case .handlerError(let error):
            
            let displayError = DisplayError(error: error)
            state.ui.action = .error(displayError)
            state.core.invalidAction = state.core.action
            state.core.action = .none
            
        case .empty:
            
            state.ui.sections = [Types.Section(rows: [.empty])]
            state.ui.action = .update
            state.core.action = .none
        
        case .assets(let assets):
            
            let assets = assets.filter { $0.isSpam == false && $0.isFiat == false }
            
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
            
            if isLockedAfterUpdate != isLockForSelect || isLockedAfterUpdate != isLockForUnselect {
                state.ui.sections = sections(assets: state.core.assets,
                                             selectedAssets: state.core.selectAssets,
                                             minSelectAssets: minSelectAssets,
                                             maxSelectAssets: state.core.maxSelectAssets)
            }
        }
    }
    
    private func uiState(assets: [Asset]) -> State.UI! {
        
        let selectedAssets = assets.reduce(into: [String: Asset](), { $0[$1.id] = $1 })
        
        return AssetsSearch.State.UI(sections: sections(assets: [],
                                                        selectedAssets: selectedAssets,
                                                        minSelectAssets: minSelectAssets,
                                                        maxSelectAssets: maxSelectAssets),
                                     action: .update,
                                     maxSelectAssets: maxSelectAssets,
                                     countSelectedAssets: assets.count)
    }
    
    private func coreState(assets: [Asset]) -> State.Core! {
        
        let selectAssets = assets.reduce(into: [String: Asset].init()) { (result, asset) in
            result[asset.id] = asset
        }
        
        return AssetsSearch.State.Core(action: .none,
                                       invalidAction: nil,
                                       assets: assets,
                                       selectAssets: selectAssets,
                                       minSelectAssets: self.minSelectAssets,
                                       maxSelectAssets: self.maxSelectAssets,
                                       isInitial: false)
    }
    
    private func sections(assets: [Asset],
                          selectedAssets: [String: Asset],
                          minSelectAssets: Int,
                          maxSelectAssets: Int) -> [Types.Section] {
        
        let isLockedMax = selectedAssets.count == maxSelectAssets
        let isLockedMin = selectedAssets.count == minSelectAssets
        
        let rows = assets.map { (asset) -> Types.Row in
            let isSelected = selectedAssets[asset.id] != nil
            
            var state: AssetsSearchAssetCell.Model.State = .unselected
            
            if isSelected {
                if isLockedMin {
                    state = .lock
                } else {
                    state = .selected
                }
                
            } else {
                if isLockedMax {
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

