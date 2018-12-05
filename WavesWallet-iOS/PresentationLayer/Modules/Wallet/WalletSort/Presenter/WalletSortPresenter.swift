//
//  WalletSortPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

private extension DomainLayer.DTO.SmartAssetBalance {

    static func map(from balance: DomainLayer.DTO.SmartAssetBalance) -> WalletSort.DTO.Asset {

        let isLock = balance.asset.isWaves == true
        let isMyWavesToken = balance.asset.isMyWavesToken
        let isFavorite = balance.settings.isFavorite
        let isGateway = balance.asset.isGateway
        let isHidden = balance.settings.isHidden
        let sortLevel = balance.settings.sortLevel
        return WalletSort.DTO.Asset(id: balance.assetId,
                                    name: balance.asset.displayName,
                                    isLock: isLock,
                                    isMyWavesToken: isMyWavesToken,
                                    isFavorite: isFavorite,
                                    isGateway: isGateway,
                                    isHidden: isHidden,
                                    sortLevel: sortLevel,
                                    icon: balance.asset.icon)
    }
}


final class WalletSortPresenter: WalletSortPresenterProtocol {

    var interactor: WalletSortInteractorProtocol!
    private let disposeBag = DisposeBag()
    private let input: [DomainLayer.DTO.SmartAssetBalance]

    init(input: [DomainLayer.DTO.SmartAssetBalance]) {
        self.input = input
    }

    func system(feedbacks: [Feedback]) {

        let assets = self.input.map { DomainLayer.DTO.SmartAssetBalance.map(from: $0) }

        let newFeedbacks = feedbacks

        Driver.system(initialState: WalletSort.State.initialState(assets: assets),
                      reduce: { [weak self] state, event in
                        return self?.reduce(state: state, event: event) ?? state
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

    private func reduce(state: inout WalletSort.State, event: WalletSort.Event) {

        switch event {
        case .dragAsset(let sourceIndexPath, let destinationIndexPath):



            let movableAsset = state
                .sections[sourceIndexPath.section]
                .items[sourceIndexPath.row].asset
            let toAsset = state
                .sections[destinationIndexPath.section]
                .items[destinationIndexPath.row].asset

            if let movableAsset = movableAsset, let toAsset = toAsset {
                if sourceIndexPath.row > destinationIndexPath.row {

                    debug("asset \(movableAsset.name)")
                    debug("overAsset \(toAsset.name)")

                    interactor.move(asset: movableAsset, overAsset: toAsset)
                } else {
                    debug("asset \(movableAsset.name)")
                    debug("underAsset \(toAsset.name)")
                    interactor.move(asset: movableAsset, underAsset: toAsset)
                }
            }

            state.moveRow(state: &state,
                          sourceIndexPath: sourceIndexPath,
                          destinationIndexPath: destinationIndexPath)
            state.action = .refresh

        case .readyView:
            state.isNeedRefreshing = true

        case .tapHidden(let indexPath):

            guard let asset = state
                .sections[indexPath.section]
                .items[indexPath.row]
                .asset else { return }

            interactor.setHidden(assetId: asset.id, isHidden: !asset.isHidden)

            state.toogleHiddenAsset(state: &state,
                                    indexPath: indexPath)
            state.action = .none

        case .tapFavoriteButton(let indexPath):

            guard let asset = state
                .sections[indexPath.section]
                .items[indexPath.row]
                .asset else { return }

            interactor.setFavorite(assetId: asset.id, isFavorite: !asset.isFavorite)

            state.toogleFavoriteAsset(state: &state,
                                      indexPath: indexPath)

            state.action = .refresh

        case .setStatus(let status):

            state.status = status
            state.action = .refresh

        case .setAssets(let assets):

            state.isNeedRefreshing = false
            state.sections = WalletSort.ViewModel.map(from: assets)
            state.action = .refresh
        }
    }
}

extension WalletSort.State {

    static func initialState(assets: [WalletSort.DTO.Asset]) -> WalletSort.State {
        return WalletSort.State(isNeedRefreshing: false,
                                status: .visibility,
                                sections: WalletSort.ViewModel.map(from: assets),
                                action: .refresh)
    }

    func moveRow(state: inout WalletSort.State, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {

        let section = state
            .sections[sourceIndexPath.section]
            .moveRow(sourceIndex: sourceIndexPath.row,
                     destinationIndex: destinationIndexPath.row)

        state.sections[sourceIndexPath.section] = section
    }

    func toogleHiddenAsset(state: inout WalletSort.State, indexPath: IndexPath) {
        guard let asset = sections[indexPath.section].items[indexPath.row].asset else { return }
        guard asset.isLock == false else { return }

        let section = sections[indexPath.section].mutate { section in
            var newAsset = asset
            newAsset.isHidden = !asset.isHidden
            if section.kind == .all {
                section.items[indexPath.row] = .asset(newAsset)
            }
        }

        state.sections[indexPath.section] = section
    }

    func toogleFavoriteAsset(state: inout WalletSort.State, indexPath: IndexPath) {
        guard let asset = sections[indexPath.section].items[indexPath.row].asset else { return }

        guard asset.isLock == false else { return }

        let favoriteSection = sections.enumerated().first { $0.element.kind == .favorities }
        let allSection = sections.enumerated().first { $0.element.kind == .all }

        guard var newFavoriteSection = favoriteSection?.element else { return }
        guard var newAllSection = allSection?.element else { return }
        guard let favoriteSectionIndex = favoriteSection?.offset else { return }
        guard let allSectionIndex = allSection?.offset else { return }

        let newAsset = asset.mutate { $0.isFavorite = !$0.isFavorite }

        newFavoriteSection = newFavoriteSection.mutate { section in
            if asset.isFavorite {
                var items = section.items
                items.remove(at: indexPath.row)
                section.items = items
            } else {
                var items = section.items
                items.insert(.favorityAsset(newAsset), at: items.count)
                section.items = items
            }
        }

        newAllSection = newAllSection.mutate { section in
            if asset.isFavorite {
                var items = section.items
                items.insert(.asset(newAsset), at: 0)
                section.items = items
            } else {
                var items = section.items
                items.remove(at: indexPath.row)
                section.items = items
            }
        }

        state.sections[favoriteSectionIndex] = newFavoriteSection
        state.sections[allSectionIndex] = newAllSection
    }
}

private extension WalletSort.ViewModel.Section {
    func moveRow(sourceIndex: Int, destinationIndex: Int) -> WalletSort.ViewModel.Section {
        return mutate { section in
            let row = section.items.remove(at: sourceIndex)
            section.items.insert(row, at: destinationIndex)
        }
    }
}

private extension WalletSort.ViewModel {
    static func map(from assets: [WalletSort.DTO.Asset]) -> [WalletSort.ViewModel.Section] {
        let favoritiesAsset = assets
            .filter { $0.isFavorite }
            .sorted(by: { $0.sortLevel < $1.sortLevel })
            .map { WalletSort.ViewModel.Row.favorityAsset($0) }

        let sortedAssets = assets
            .filter { $0.isFavorite == false }
            .sorted(by: { $0.sortLevel < $1.sortLevel })
            .map { WalletSort.ViewModel.Row.asset($0) }

        return [WalletSort.ViewModel.Section(kind: .favorities,
                                             items: favoritiesAsset),
                WalletSort.ViewModel.Section(kind: .all,
                                             items: sortedAssets)]
    }
}

private extension WalletSort.ViewModel.Row {
    var asset: WalletSort.DTO.Asset? {
        switch self {
        case .asset(let asset):
            return asset

        case .favorityAsset(let asset):
            return asset
        }
    }
}
