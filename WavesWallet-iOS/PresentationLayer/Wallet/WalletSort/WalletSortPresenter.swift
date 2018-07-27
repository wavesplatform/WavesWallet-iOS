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

protocol WalletSortPresenterProtocol {
    typealias Feedback = (Driver<WalletSort.State>) -> Signal<WalletSort.Event>

    func system(bindings: @escaping Feedback)
}

final class WalletSortPresenter: WalletSortPresenterProtocol {
    private let interactor: WalletSortInteractorProtocol = WalletSortInteractor()
    private let disposeBag = DisposeBag()

    func system(bindings: @escaping Feedback) {
        Driver.system(initialState: WalletSort.State.initialState,
                      reduce: reduce,
                      feedback: bindings,
                      assetsQuery())
            .drive()
            .disposed(by: disposeBag)
    }

    private func assetsQuery() -> Feedback {
        return react(query: { _ -> String? in
            ""
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

            // TODO: Send interactor
            return state.moveRow(sourceIndexPath: sourceIndexPath,
                                 destinationIndexPath: destinationIndexPath)

        case .readyView:
            return state

        case .tapFavoriteButton(let indexPath):
            return state.toogleFavoriteAsset(indexPath: indexPath)

        case .setStatus(let status):
            return state.mutate { state in
                state.status = status
            }

        case .setAssets(let assets):
            return state.mutate { state in
                state.sections = WalletSort.ViewModel.map(from: assets)
            }
        }        
    }
}

fileprivate extension WalletSort.State {
    static var initialState: WalletSort.State {
        return WalletSort.State(status: .visibility,
                                sections: [])
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
            .map { WalletSort.ViewModel.Row.favorityAsset($0) }

        let sortedAssets = assets
            .filter { $0.isFavorite == false }
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
