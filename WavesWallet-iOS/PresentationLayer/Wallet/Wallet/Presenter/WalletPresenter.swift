//
//  WalletsViewModel.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

private enum ReactQuery {
    case new
    case refresh
}

final class WalletPresenter: WalletPresenterProtocol {

    var interactor: WalletInteractorProtocol!
    weak var moduleOutput: WalletModuleOutput?

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(queryAssets())
        newFeedbacks.append(queryLeasing())

        Driver
            .system(initialState: WalletPresenter.initialState(),
                    reduce: reduce,
                    feedback: newFeedbacks)

            .drive()
            .disposed(by: disposeBag)
    }

    private func queryAssets() -> Feedback {
        return react(query: { (state) -> Bool? in

            if state.displayState.isAppeared && state.displayState.kind == .assets {
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .interactor
                .assets()
                .map { .setAssets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func queryLeasing() -> Feedback {
        return react(query: { (state) -> Bool? in

            if state.displayState.isAppeared && state.displayState.kind == .leasing {
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .interactor
                .leasing()
                .map { .setLeasing($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func reduce(state: WalletTypes.State, event: WalletTypes.Event) -> WalletTypes.State {
        switch event {
        case .readyView:
            return state.mutate { $0.displayState.isAppeared = true }

        case .tapSortButton:
            moduleOutput?.showWalletSort()
            return state

        case .tapAddressButton:
            moduleOutput?.showMyAddress()
            return state

        case .refresh:
            switch state.displayState.kind {
            case .assets:
                interactor.refreshAssets()
            case .leasing:
                interactor.refreshLeasing()
            }
            return state.mutate { $0.displayState = $0.displayState.setIsRefreshing(isRefreshing: true) }

        case .tapRow(let indexPath):

            guard let asset = state.displayState.currentDisplay.visibleSections[indexPath.section].items[indexPath.row].asset else { return state }
            moduleOutput?.showAsset(with: asset, assets: state.assets)
            return state

        case .tapSection(let section):
            return state.mutate { $0.displayState = $0.displayState.toggleCollapse(index: section) }

        case .changeDisplay(let kind):
            return state.changeDisplay(kind: kind)

        case .setAssets(let response):

            return state.mutate {
                let sections = WalletTypes.ViewModel.Section.map(from: response)
                $0.displayState = $0.displayState.updateDisplay(kind: .assets,
                                                                sections: sections)
                $0.assets = response
            }

        case .setLeasing(let response):

            return state.mutate {
                let sections = WalletTypes.ViewModel.Section.map(from: response)
                $0.displayState = $0.displayState.updateDisplay(kind: .leasing,
                                                                sections: sections)
            }
        }
    }

    private static func initialState() -> WalletTypes.State {
        return WalletTypes.State.initialState()
    }
}
