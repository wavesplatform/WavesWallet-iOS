//
//  NewWalletSortPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

final class WalletSortPresenter: WalletSortPresenterProtocol {
    
    private let input: [DomainLayer.DTO.SmartAssetBalance]
    private let disposeBag = DisposeBag()

    var interactor: WalletSortInteractorProtocol!
    
    init(input: [DomainLayer.DTO.SmartAssetBalance]) {
        self.input = input
    }
    
    func system(feedbacks: [WalletSortPresenterProtocol.Feedback]) {
        
        let assets = input.filter{ $0.asset.isSpam == false }.map { DomainLayer.DTO.SmartAssetBalance.map(from: $0) }

        let newFeedbacks = feedbacks        

        Driver.system(initialState: WalletSort.State.initialState(assets: assets),
                      reduce: { [weak self] state, event in
                        guard let self = self else { return state }
                        return self.reduce(state: state, event: event)
            },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func reduce(state: WalletSort.State, event: WalletSort.Event) -> WalletSort.State {
        
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }
    
    private func reduce(state: inout WalletSort.State, event: WalletSort.Event)  {
        
        switch event {
            
        case .readyView:
            state.action = .refresh
            
        case .setStatus(let status):
            state.status = status
            state.action = .refresh
            
        case .moveAsset(let from, let to):
            
            if let asset = state.sections[from.section].items[from.row].asset {

                state.sections[from.section].items.remove(at: from.row)
                
                let newSection = state.sections[to.section].kind
                
                var newAsset = asset

                if newSection  == .favorities {
                    newAsset.isFavorite = true
                    newAsset.isHidden = false
                    
                    state.sections[to.section].items.insert(.favorityAsset(newAsset), at: to.row)
                }
                else if newSection == .list {
                    newAsset.isFavorite = false
                    newAsset.isHidden = false
                    
                    state.sections[to.section].items.insert(.list(newAsset), at: to.row)
                }
                else if newSection == .hidden {
                    newAsset.isFavorite = false
                    newAsset.isHidden = true
                    
                    state.sections[to.section].items.insert(.hidden(newAsset), at: to.row)
                }
                
                state.assets.removeAll()

                for section in state.sections {
                    for row in section.items {
                        if let asset = row.asset {
                            state.assets.append(asset)
                        }
                    }
                }
                
                updateWithNewAsset(newAsset, state: &state)
            }
            
            
        case .setHidden(let asset):
            
            var newAsset = asset
            newAsset.isHidden = !asset.isHidden
            newAsset.isFavorite = false
            
            if let index = state.assets.firstIndex(where: {$0.id == asset.id}) {
                state.assets.remove(at: index)
                
               
                if newAsset.isHidden {
                    //asset was in list, we need add asset to top of the hidden assets
                    if let firstHiddenIndex = state.assets.firstIndex(where: {$0.isHidden}) {
                        state.assets.insert(newAsset, at: firstHiddenIndex)
                    }
                    else {
                        state.assets.append(newAsset)
                    }
                }
                else {
                    //asset was hidden. we need add asset to the bottom of list
                    if let lastListIndex = state.assets.lastIndex(where: {$0.isFavorite == false && $0.isHidden == false}) {
                        state.assets.insert(newAsset, at: lastListIndex + 1)
                    }
                    else {
                        if let lastIndexFavorites = state.assets.lastIndex(where: {$0.isFavorite}) {
                            state.assets.insert(newAsset, at: lastIndexFavorites + 1)
                        }
                        else {
                            state.assets.insert(newAsset, at: 0)
                        }
                    }
                }
                
            }
            
            updateWithNewAsset(newAsset, state: &state)
            
        case .setFavorite(let asset):
            
            var newAsset = asset
            newAsset.isFavorite = !asset.isFavorite
            newAsset.isHidden = false
            
            if let index = state.assets.firstIndex(where: {$0.id == asset.id}) {
                state.assets.remove(at: index)
                
                
                if newAsset.isFavorite {
                    //asset was in list / hidden, we need insert asset to the bottom of favorites
                    if let lastIndexFavorites = state.assets.lastIndex(where: {$0.isFavorite}) {
                        state.assets.insert(newAsset, at: lastIndexFavorites + 1)
                    }
                    else {
                        state.assets.insert(newAsset, at: 0)
                    }
                }
                else {
                    // asset was in favorite, we need insert asset at the top of list
                    if let firstListIndex = state.assets.firstIndex(where: {$0.isFavorite == false && $0.isHidden == false}) {
                        state.assets.insert(newAsset, at: firstListIndex)
                    }
                    else {
                        if let lastIndexFavorites = state.assets.lastIndex(where: {$0.isFavorite}) {
                            state.assets.insert(newAsset, at: lastIndexFavorites + 1)
                        }
                        else {
                            state.assets.insert(newAsset, at: 0)
                        }
                    }
                }
            }
            
            updateWithNewAsset(newAsset, state: &state)
        }
        
    }
}

private extension WalletSortPresenter {
    
    func updateWithNewAsset(_ asset: WalletSort.DTO.Asset, state: inout WalletSort.State) {
        
        for index in 0..<state.assets.count {
            state.assets[index].sortLevel = Float(index)
        }

        state.sections = WalletSort.ViewModel.map(assets: state.assets)
        state.action = .refresh
        
        interactor.updateAssetSettings(assets: state.assets)
    }

}

private extension WalletSort.State {
    
    static func initialState(assets: [WalletSort.DTO.Asset]) -> WalletSort.State {
        
        return WalletSort.State(assets: assets,
                                   status: .position,
                                   sections: WalletSort.ViewModel.map(assets: assets),
                                   action: .none)
    }
}

private extension DomainLayer.DTO.SmartAssetBalance {
    
    static func map(from balance: DomainLayer.DTO.SmartAssetBalance) -> WalletSort.DTO.Asset {
        
        let isMyWavesToken = balance.asset.isMyWavesToken
        let isFavorite = balance.settings.isFavorite
        let isGateway = balance.asset.isGateway
        let isHidden = balance.settings.isHidden
        let sortLevel = balance.settings.sortLevel
        return WalletSort.DTO.Asset(id: balance.assetId,
                                       name: balance.asset.displayName,
                                       isMyWavesToken: isMyWavesToken,
                                       isFavorite: isFavorite,
                                       isGateway: isGateway,
                                       isHidden: isHidden,
                                       sortLevel: sortLevel,
                                       icon: balance.asset.iconLogo,
                                       isSponsored: balance.asset.isSponsored,
                                       hasScript: balance.asset.hasScript)
    }
}

