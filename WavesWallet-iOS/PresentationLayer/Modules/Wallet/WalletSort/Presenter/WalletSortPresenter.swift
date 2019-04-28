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
            state.action = .refreshWithAnimation
            
        case .moveAsset(let from, let to):
            move(from: from, to: to, state: &state)
            
        case .setHiddenAt(let indexPath):
            setHidden(at: indexPath, state: &state)
            
        case .setFavoriteAt(let indexPath):
            setFavorite(at: indexPath, state: &state)
        }
        
    }
}

private extension WalletSortPresenter {
    
    func update(state: inout WalletSort.State) {
        
        state.assets.removeAll()
        for section in state.sections {
            for row in section.items {
                if let asset = row.asset {
                    state.assets.append(asset)
                }
            }
        }
        
        for index in 0..<state.assets.count {
            state.assets[index].sortLevel = Float(index)
        }

        state.sections = WalletSort.ViewModel.map(assets: state.assets)
        
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
    
    
    func sectionIndex(_ kind: WalletSort.ViewModel.Section.Kind) -> Int {
        return sections.firstIndex(where: {$0.kind == kind}) ?? 0
    }
    
    func asset(by indexPath: IndexPath) -> WalletSort.DTO.Asset? {
        return sections[indexPath.section].items[indexPath.row].asset
    }
    
    func isEmptySection(_ kind: WalletSort.ViewModel.Section.Kind) -> Bool {
        return sections[sectionIndex(kind)].items.filter{ $0.asset != nil }.count == 0
    }
    
    func lastVisibleAssetRow(_ kind: WalletSort.ViewModel.Section.Kind) -> Int {
        
        if isEmptySection(kind) {
            return 0
        }
        return sections[sectionIndex(kind)].items.count - 1
    }
    
    func kind(by indexPath: IndexPath) -> WalletSort.ViewModel.Section.Kind {
        return sections[indexPath.section].kind
    }
    
    func blockIndexPath(by kind: WalletSort.ViewModel.Section.Kind) -> IndexPath {
        return IndexPath(row: 0, section: sectionIndex(kind))
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


//MARK: - SetFavorite
private extension WalletSortPresenter {
    
    func setFavorite(at indexPath: IndexPath, state: inout WalletSort.State) {
        
        if var asset = state.asset(by: indexPath) {
            
            state.sections[indexPath.section].items.remove(at: indexPath.row)
            
            if asset.isFavorite {
                asset.isFavorite = false
                
                let listSection = state.sectionIndex(.list)
                let to = IndexPath(row: 0, section: listSection)
                
                if state.isEmptySection(.favorities) && state.isEmptySection(.list) {
                    
                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .list),
                                         insert: state.blockIndexPath(by: .favorities))
                }
                else if state.isEmptySection(.favorities) {
                    
                    state.action = .move(at: indexPath, to: to,
                                         delete: nil,
                                         insert: state.blockIndexPath(by: .favorities))
                }
                else if state.isEmptySection(.list) {
                    
                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .list),
                                         insert: nil)
                }
                else {
                    state.action = .move(at: indexPath, to: to,
                                         delete: nil,
                                         insert: nil)
                }
                state.sections[listSection].items.insert(.list(asset), at: 0)
            }
            else {
                asset.isFavorite = true
                asset.isHidden = false
                
                let favoriteSection = state.sectionIndex(.favorities)
                
                let kind = state.kind(by: indexPath)
                let to = IndexPath(row: state.lastVisibleAssetRow(.favorities), section: favoriteSection)

                if state.isEmptySection(.favorities) && state.isEmptySection(kind) {

                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .favorities),
                                         insert: state.blockIndexPath(by: kind))
                }
                else if state.isEmptySection(.favorities) {

                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .favorities),
                                         insert: nil)
                }
                else if state.isEmptySection(kind) {
                    
                    state.action = .move(at: indexPath, to: to,
                                         delete: nil,
                                         insert: state.blockIndexPath(by: kind))
                }
                else {
                    state.action = .move(at: indexPath, to: to, delete: nil, insert: nil)
                }
                
                state.sections[favoriteSection].items.append(.favorityAsset(asset))
            }
            
            update(state: &state)
        }
    }
}

//MARK: - SetHidden
private extension WalletSortPresenter {
    func setHidden(at indexPath: IndexPath, state: inout WalletSort.State) {
        if var asset = state.asset(by: indexPath) {
            
            state.sections[indexPath.section].items.remove(at: indexPath.row)
            
            if asset.isHidden {
                asset.isHidden = false
                
                let listSection = state.sectionIndex(.list)
                let to = IndexPath(row: state.lastVisibleAssetRow(.list), section: listSection)

                if state.isEmptySection(.hidden) && state.isEmptySection(.list) {
                    
                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .list),
                                         insert: state.blockIndexPath(by: .hidden))
                }
                else if state.isEmptySection(.hidden) {
                    state.action = .move(at: indexPath, to: to,
                                         delete: nil,
                                         insert: state.blockIndexPath(by: .hidden))
                }
                else if state.isEmptySection(.list) {
                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .list),
                                         insert: nil)
                }
                else {
                    state.action = .move(at: indexPath, to: to, delete: nil, insert: nil)
                }
                
                state.sections[listSection].items.append(.list(asset))
            }
            else {
                asset.isHidden = true
                asset.isFavorite = false
                
                let hiddenSection = state.sectionIndex(.hidden)
                let to = IndexPath(row: 0, section: hiddenSection)
                let kind = state.kind(by: indexPath)
                
                if state.isEmptySection(.hidden) && state.isEmptySection(kind) {
                    
                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .hidden),
                                         insert: state.blockIndexPath(by: kind))
                }
                else if state.isEmptySection(.hidden) {

                    state.action = .move(at: indexPath, to: to,
                                         delete: state.blockIndexPath(by: .hidden),
                                         insert: nil)
                }
                else if state.isEmptySection(kind) {

                    state.action = .move(at: indexPath, to: to,
                                         delete: nil,
                                         insert: state.blockIndexPath(by: kind))
                }
                else {
                    state.action = .move(at: indexPath, to: to,
                                         delete: nil,
                                         insert: nil)
                }
                state.sections[hiddenSection].items.insert(.hidden(asset), at: 0)
            }
            
            update(state: &state)
        }
    }
}

//MARK: - Move
private extension WalletSortPresenter {
    
    func move(from: IndexPath, to: IndexPath, state: inout WalletSort.State) {
        
        if var asset = state.asset(by: from) {
            
            state.sections[from.section].items.remove(at: from.row)
            
            let newSection = state.sections[to.section].kind
            
            if newSection == .favorities {
                asset.isFavorite = true
                asset.isHidden = false
                
                updateSectionsWithMoveAction(from: from, to: to, state: &state)
                
                state.sections[to.section].items.insert(.favorityAsset(asset), at: to.row)
            }
            else if newSection == .list {
                asset.isFavorite = false
                asset.isHidden = false
                
                updateSectionsWithMoveAction(from: from, to: to, state: &state)

                state.sections[to.section].items.insert(.list(asset), at: to.row)
            }
            else if newSection == .hidden {
                asset.isFavorite = false
                asset.isHidden = true
                
                updateSectionsWithMoveAction(from: from, to: to, state: &state)

                state.sections[to.section].items.insert(.hidden(asset), at: to.row)
            }
            
            update(state: &state)
        }
    }
    
    func updateSectionsWithMoveAction(from: IndexPath, to: IndexPath, state: inout WalletSort.State) {
        
        let newSection = state.sections[to.section].kind
        let lastSection = state.sections[from.section].kind
        let isSameSection = newSection == lastSection
        
        let block = state.blockIndexPath(by: newSection)
        let deletedIndexPath = IndexPath(row: block.row + 1, section: block.section)
        
        if state.isEmptySection(newSection) && state.isEmptySection(lastSection) && !isSameSection {
            state.action = .updateMoveAction(insertAt: state.blockIndexPath(by: lastSection),
                                             deleteAt: deletedIndexPath,
                                             movedRowAt: to)
        }
        else if state.isEmptySection(newSection) && !isSameSection {
            
            state.action = .updateMoveAction(insertAt: nil, deleteAt: deletedIndexPath,
                                             movedRowAt: to)
        }
        else if state.isEmptySection(lastSection) && !isSameSection {
            state.action = .updateMoveAction(insertAt: state.blockIndexPath(by: lastSection),
                                             deleteAt: nil,
                                             movedRowAt: to)
        }
        else {
            state.action = .finishUpdateMoveAction(movedRowAt: to)
        }
    }
}
