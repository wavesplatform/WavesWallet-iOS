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

    private var assetListener: Signal<WalletTypes.Event>?
    private var leasingListener: Signal<WalletTypes.Event>?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(queryAssets())
        newFeedbacks.append(queryAssetsListener())
        newFeedbacks.append(queryLeasing())
        newFeedbacks.append(queryLeasingListener())

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
        return react(request: { (state) -> Types.DisplayState.RefreshData? in

            if state.displayState.kind == .assets && state.displayState.refreshData != .none {
                return state.displayState.refreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            let signal = strongSelf
                .interactor
                .assets()                
                .map { .setAssets($0) }
                .share()
                .asSignal(onErrorRecover: { Signal<WalletTypes.Event>.just(.handlerError($0)) })

            strongSelf.assetListener = signal
            return signal
        })
    }

    private func queryAssetsListener() -> Feedback {
        return react(request: { (state) -> Types.DisplayState.RefreshData? in

            if state.displayState.kind == .assets {
                return state.displayState.listenerRefreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.assetListener?.skip(1) ?? Signal.never()
        })
    }

    private func queryLeasingListener() -> Feedback {
        return react(request: { (state) -> Types.DisplayState.RefreshData? in

            if state.displayState.kind == .leasing {
                return state.displayState.listenerRefreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.leasingListener?.skip(1) ?? Signal.never()
        })
    }

    private func queryLeasing() -> Feedback {
        return react(request: { (state) -> Types.DisplayState.RefreshData? in

            if state.displayState.kind == .leasing {
                return state.displayState.refreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            let listener = strongSelf
                .interactor
                .leasing()
                .share()
                .map { .setLeasing($0) }
                .asSignal(onErrorRecover: { Signal<WalletTypes.Event>.just(.handlerError($0)) })

            strongSelf.leasingListener = listener
            return listener
        })
    }


    private func reduce(state: WalletTypes.State, event: WalletTypes.Event) -> WalletTypes.State {

        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    private func resetAnimateType(state: inout WalletTypes.State) {

        var currentDisplay = state.displayState.currentDisplay
        currentDisplay.animateType = .none
        state.displayState.currentDisplay = currentDisplay
    }

    private func reduce(state: inout WalletTypes.State, event: WalletTypes.Event) {
        resetAnimateType(state: &state)

        switch event {
        case .viewWillAppear:
            state.displayState.isAppeared = true
            state.displayState.refreshData = .refresh

            var hasData = false

            switch state.displayState.kind {
            case .assets:
                hasData = state.assets.count > 0

            case .leasing:
                hasData = state.leasing != nil
            }
            if hasData == false {
                var currentDisplay = state.displayState.currentDisplay
                currentDisplay.animateType = .refresh(animated: false)
                state.displayState.currentDisplay = currentDisplay
            }

        case .viewDidDisappear:
            state.displayState.isAppeared = false
            state.displayState.leasing.animateType = .none
            state.displayState.assets.animateType = .none
            state.displayState.refreshData = .none

        case .handlerError(let error):
            state.displayState = state.displayState.setIsRefreshing(isRefreshing: false)
            state.displayState.refreshData = .none

            var hasData = false

            switch state.displayState.kind {
            case .assets:
                hasData = state.assets.count > 0

            case .leasing:
                hasData = state.leasing != nil
            }

            let errorStatus = DisplayErrorState.displayErrorState(hasData: hasData, error: error)
            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.errorState = errorStatus
            currentDisplay.animateType = .refreshOnlyError
            state.displayState.currentDisplay = currentDisplay

        case .tapSortButton:
            moduleOutput?.showWalletSort(balances: state.assets)

        case .tapAddressButton:
            moduleOutput?.showMyAddress()

        case .refresh:
            if state.displayState.refreshData == .update {
                state.displayState.refreshData = .refresh
            } else {
                state.displayState.refreshData = .update
            }


            var hasData = false

            switch state.displayState.kind {
            case .assets:
                hasData = state.assets.count > 0

            case .leasing:
                hasData = state.leasing != nil
            }

            var currentDisplay = state.displayState.currentDisplay

            if hasData == false {
                currentDisplay.sections = WalletTypes.DisplayState.Display.skeletonSections(kind: state.displayState.kind)
                currentDisplay.errorState = .none
                currentDisplay.animateType = .refresh(animated: false)
            }
            currentDisplay.isRefreshing = true
            state.displayState.currentDisplay = currentDisplay

        case .tapRow(let indexPath):

            let section = state.displayState.currentDisplay.visibleSections[indexPath.section]

            switch section.kind {
            case .balance:
                let row = section.items[indexPath.row]
                if case .allHistory = row {
                    moduleOutput?.showHistoryForLeasing()
                }

            case .hidden:
                guard let asset = section.items[indexPath.row].asset else { return  }
                moduleOutput?.showAsset(with: asset, assets: state.assets.filter { $0.settings.isHidden == true } )

            case .spam:
                guard let asset = section.items[indexPath.row].asset else { return  }
                moduleOutput?.showAsset(with: asset, assets: state.assets.filter { $0.asset.isSpam == true } )

            case .general:
                guard let asset = section.items[indexPath.row].asset else { return  }
                moduleOutput?.showAsset(with: asset, assets: state.assets.filter { $0.asset.isSpam != true && $0.settings.isHidden != true } )
            case .transactions:
                let leasingTransactions = section
                    .items
                    .map { $0.leasingTransaction }
                    .compactMap { $0 }
                moduleOutput?.showLeasingTransaction(transactions: leasingTransactions, index: indexPath.row)
            default:
                break
            }

        case .tapSection(let section):
            state.displayState = state.displayState.toggleCollapse(index: section)

        case .changeDisplay(let kind):
            state.changeDisplay(state: &state, kind: kind)
            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.isRefreshing = false
            state.displayState.currentDisplay = currentDisplay

        case .setAssets(let response):

            let sections = WalletTypes.ViewModel.Section.map(from: response)
            state.displayState = state.displayState.updateDisplay(kind: .assets,
                                                                  sections: sections)

            state.assets = response

            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.isRefreshing = false
            currentDisplay.errorState = .none

            state.displayState.currentDisplay = currentDisplay

            if state.displayState.refreshData != .none {
                state.displayState.listenerRefreshData = state.displayState.refreshData
            }

        case .setLeasing(let response):

            let sections = WalletTypes.ViewModel.Section.map(from: response)
            state.displayState = state.displayState.updateDisplay(kind: .leasing,
                                                                  sections: sections)
            state.leasing = response

            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.errorState = .none
            currentDisplay.isRefreshing = false
            state.displayState.currentDisplay = currentDisplay

            if state.displayState.refreshData != .none {
                state.displayState.listenerRefreshData = state.displayState.refreshData
            }

        case .showStartLease(let money):
            moduleOutput?.showStartLease(availableMoney: money)
        }
    }

    private static func initialState() -> WalletTypes.State {
        return WalletTypes.State.initialState()
    }
}
