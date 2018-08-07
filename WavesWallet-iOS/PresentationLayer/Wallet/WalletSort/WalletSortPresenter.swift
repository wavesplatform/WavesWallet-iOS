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

final class WalletSortPresenter: WalletSortPresenterProtocol {

    private let interactor: WalletSortInteractorProtocol = WalletSortInteractor()
    private let disposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(assetsQuery())

        Driver.system(initialState: WalletSort.State.initialState,
                      reduce: reduce,
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }

    private func assetsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return state.isNeedRefreshing == true ? true : nil
        }, effects: { [weak self] _ -> Signal<WalletSort.Event> in

            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .interactor
                .assets()
                .map { .setAssets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func reduce(state: WalletSort.State, event: WalletSort.Event) -> WalletSort.State {
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
                    interactor.move(asset: movableAsset, overAsset: toAsset)
                } else {
                    interactor.move(asset: movableAsset, underAsset: toAsset)
                }
            }

            return state.moveRow(sourceIndexPath: sourceIndexPath,
                                 destinationIndexPath: destinationIndexPath)
                .changeAction(.refresh)

        case .readyView:
            return state.mutate {  $0.isNeedRefreshing = true }

        case .tapHidden(let indexPath):

            if var asset = state
                .sections[indexPath.section]
                .items[indexPath.row]
                .asset {
                asset.isHidden = !asset.isHidden
                interactor.update(asset: asset)
            }

            return state.toogleHiddenAsset(indexPath: indexPath)
                .changeAction(.none)

        case .tapFavoriteButton(let indexPath):

            if var asset = state
                .sections[indexPath.section]
                .items[indexPath.row]
                .asset {
                asset.isFavorite = !asset.isFavorite
                interactor.update(asset: asset)
            }

            return state.toogleFavoriteAsset(indexPath: indexPath)
                .changeAction(.refresh)

        case .setStatus(let status):
            return state.mutate { state in
                state.status = status
            }
            .changeAction(.refresh)

        case .setAssets(let assets):
            return state.mutate { state in
                state.isNeedRefreshing = false
                state.sections = WalletSort.ViewModel.map(from: assets)
            }
            .changeAction(.refresh)
        }
    }
}

fileprivate extension WalletSort.State {
    static var initialState: WalletSort.State {
        return WalletSort.State(isNeedRefreshing: false,
                                status: .visibility,
                                sections: [],
                                action: .none)
    }

    func changeAction(_ action: WalletSort.State.Action) -> WalletSort.State {
        return mutate { state in
            state.action = action
        }
    }

    func moveRow(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) -> WalletSort.State {
        return mutate { state in
            let section = state
                .sections[sourceIndexPath.section]
                .moveRow(sourceIndex: sourceIndexPath.row,
                         destinationIndex: destinationIndexPath.row)

            state.sections[sourceIndexPath.section] = section
        }
    }

    func toogleHiddenAsset(indexPath: IndexPath) -> WalletSort.State {
        guard let asset = sections[indexPath.section].items[indexPath.row].asset else { return self }
        guard asset.isLock == false else { return self }

        let section = sections[indexPath.section].mutate { section in
            var newAsset = asset
            newAsset.isHidden = !asset.isHidden
            if section.kind == .all {
                section.items[indexPath.row] = .asset(newAsset)
            }
        }

        return self.mutate { state in
            state.sections[indexPath.section] = section
        }
    }

    func toogleFavoriteAsset(indexPath: IndexPath) -> WalletSort.State {
        guard let asset = sections[indexPath.section].items[indexPath.row].asset else { return self }

        guard asset.isLock == false else { return self }

        let favoriteSection = sections.enumerated().first { $0.element.kind == .favorities }
        let allSection = sections.enumerated().first { $0.element.kind == .all }

        guard var newFavoriteSection = favoriteSection?.element else { return self }
        guard var newAllSection = allSection?.element else { return self }
        guard let favoriteSectionIndex = favoriteSection?.offset else { return self }
        guard let allSectionIndex = allSection?.offset else { return self }

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

        return mutate { state in
            state.sections[favoriteSectionIndex] = newFavoriteSection
            state.sections[allSectionIndex] = newAllSection
        }
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
