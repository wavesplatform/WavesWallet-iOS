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

    typealias Types = WalletTypes

    var interactor: WalletInteractorProtocol!
    weak var moduleOutput: WalletModuleOutput?

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(queryAssets())
        newFeedbacks.append(queryLeasing())

        Driver
            .system(initialState: WalletPresenter.initialState(),
                    reduce: { [weak self] state, event -> Types.State in
                        return self?.reduce(state: state, event: event) ?? state
                    },
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

            let section = state.displayState.currentDisplay.visibleSections[indexPath.section]

            switch section.kind {
            case .balance:
                let row = section.items[indexPath.row]
                if case .allHistory = row {
                    moduleOutput?.showHistoryForLeasing()
                }

            case .hidden:
                guard let asset = section.items[indexPath.row].asset else { return state }
                moduleOutput?.showAsset(with: asset, assets: state.assets.filter { $0.isHidden == true } )

            case .spam:
                guard let asset = section.items[indexPath.row].asset else { return state }
                moduleOutput?.showAsset(with: asset, assets: state.assets.filter { $0.isSpam == true } )

            case .general:
                guard let asset = section.items[indexPath.row].asset else { return state }
                moduleOutput?.showAsset(with: asset, assets: state.assets.filter { $0.isSpam != true && $0.isHidden != true } )
            case .transactions:
                let leasingTransactions = section
                    .items
                    .map { $0.leasingTransaction }
                    .compactMap { $0 }
                moduleOutput?.showLeasingTransaction(transactions: leasingTransactions, index: indexPath.row)
            default:
                break
            }

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
            
        case .showStartLease(let money):
            moduleOutput?.showStartLease(availableMoney: money)
            return state
        }
    }

    private static func initialState() -> WalletTypes.State {
        return WalletTypes.State.initialState()
    }
}
