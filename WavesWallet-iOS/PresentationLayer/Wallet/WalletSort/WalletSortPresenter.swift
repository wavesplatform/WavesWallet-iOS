//
//  WalletSortPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

protocol WalletSortPresenterProtocol {
    typealias Feedback = (Driver<WalletSort.State>) -> Signal<WalletSort.Event>

    func system(bindings: @escaping Feedback)
}

final class WalletSortPresenter: WalletSortPresenterProtocol {

    private let interactor: WalletSortInteractorProtocol = WalletSortInteractorMock()
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
        return react(query: { state -> String? in
            return ""
        }, effects: { [weak self] _ -> Signal<WalletSort.Event> in

            //TODO: Error
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

            var sections = state.sections
            let section = sections[sourceIndexPath.section]
            let newSection = section.moveRow(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)

            sections[sourceIndexPath.section] = newSection

            return state.setSections(sections)
        case .readyView:
            return state
        case .tapFavoriteButton(let indexPath):
            return state
        case .setAssets(let assets):

            let sections = WalletSort.ViewModel.map(assets: assets)
            return state.setSections(sections)
        }

        return state
    }
}

fileprivate extension WalletSort.State {

    static var initialState: WalletSort.State {
        return WalletSort.State(status: .position,
                                sections: [])
    }

    func setSections(_ sections: [WalletSort.ViewModel.Section]) -> WalletSort.State {
        var newState = self
        newState.sections = sections
        return newState
    }
}

fileprivate extension WalletSort.ViewModel.Section {

    func moveRow(sourceIndex: Int, destinationIndex: Int) -> WalletSort.ViewModel.Section {

        var newSection = self
        var newItems: [WalletSort.ViewModel.Row]  = self.items

        var row = newItems.remove(at: sourceIndex)
        newItems.insert(row, at: destinationIndex)
        newSection.items = newItems

        return newSection
    }
}

private extension WalletSort.ViewModel {

    static func map(assets: [WalletSort.DTO.Asset]) -> [WalletSort.ViewModel.Section] {

        let favoritiesAsset = assets
            .filter { $0.isFavorite }
            .sorted(by: { $0.sortLevel > $1.sortLevel })
            .map { WalletSort.ViewModel.Row.favorityAsset($0) }

        let sortedAssets = assets
            .filter { $0.isFavorite == false }
            .sorted(by: { $0.sortLevel > $1.sortLevel })
            .map { WalletSort.ViewModel.Row.asset($0) }

        return [WalletSort.ViewModel.Section(kind: .favorities,
                                             items: favoritiesAsset),
                WalletSort.ViewModel.Section(kind: .all,
                                             items: sortedAssets)]
    }
}
