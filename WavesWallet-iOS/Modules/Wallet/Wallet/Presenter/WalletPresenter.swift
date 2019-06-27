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
import DomainLayer
import Extensions

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
        newFeedbacks.append(queryCleanWallet())
        newFeedbacks.append(queryCleanWalletBanner())
        newFeedbacks.append(queryAppUpdate())

        Driver
            .system(initialState: WalletPresenter.initialState(),
                    reduce: { [weak self] state, event -> Types.State in
                        return self?.reduce(state: state, event: event) ?? state
                    },
                    feedback: newFeedbacks)

            .drive()
            .disposed(by: disposeBag)
    }

    private func queryAppUpdate() -> Feedback {
        return react(request: { (state) -> Bool? in
            return true
            
        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in
            
            guard let self = self else { return Signal.empty() }
            return self.interactor.isHasAppUpdate().map {.isHasAppUpdate($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func queryCleanWalletBanner() -> Feedback {
        return react(request: { (state) -> Bool? in
            return state.isNeedCleanWalletBanner ? true : nil
            
        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in
            
            guard let self = self else { return Signal.empty() }
            return self.interactor.setCleanWalletBanner().map{ .completeCleanWalletBanner($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func queryCleanWallet() -> Feedback {
        return react(request: { (state) -> Bool? in
            return true
            
        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in
            
            guard let self = self else { return Signal.empty() }
            return self.interactor.isShowCleanWalletBanner().map{ .isShowCleanWalletBanner($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func queryAssets() -> Feedback {
        return react(request: { (state) -> Types.DisplayState.RefreshData? in

            if state.displayState.kind == .assets && state.displayState.refreshData != .none {
                return state.displayState.refreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in

            guard let self = self else { return Signal.empty() }
            let signal = self
                .interactor
                .assets()                
                .map { .setAssets($0) }
                .asSignal(onErrorRecover: { Signal<WalletTypes.Event>.just(.handlerError($0)) })

            self.assetListener = signal
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

            guard let self = self else { return Signal.empty() }
            return self.assetListener?.skip(1) ?? Signal.never()
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

            guard let self = self else { return Signal.empty() }
            return self.leasingListener?.skip(1) ?? Signal.never()
        })
    }

    private func queryLeasing() -> Feedback {
        return react(request: { (state) -> Types.DisplayState.RefreshData? in

            if state.displayState.kind == .leasing && state.displayState.refreshData != .none {
                return state.displayState.refreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in

            guard let self = self else { return Signal.empty() }
            let listener = self
                .interactor
                .leasing()                
                .map { .setLeasing($0) }
                .asSignal(onErrorRecover: { Signal<WalletTypes.Event>.just(.handlerError($0)) })

            self.leasingListener = listener
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

            if state.hasData == false {
                var currentDisplay = state.displayState.currentDisplay
                currentDisplay.animateType = .refresh(animated: false)
                state.displayState.currentDisplay = currentDisplay
                state.action = .update
            }
            else {
                state.action = .none
            }
            
        case .viewDidDisappear:
            state.displayState.isAppeared = false
            state.displayState.leasing.animateType = .none
            state.displayState.assets.animateType = .none
            state.displayState.refreshData = .none
            state.action = .none

        case .handlerError(let error):
            state.displayState = state.displayState.setIsRefreshing(isRefreshing: false)
            state.displayState.refreshData = .none

            let errorStatus = DisplayErrorState.displayErrorState(hasData: state.hasData, error: error)
            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.errorState = errorStatus
            currentDisplay.animateType = .refreshOnlyError
            state.displayState.currentDisplay = currentDisplay
            state.action = .update

        case .tapSortButton:
            moduleOutput?.showWalletSort(balances: state.assets)
            state.action = .none

        case .tapAddressButton:
            moduleOutput?.showMyAddress()
            state.action = .none

        case .refresh:
            if state.displayState.refreshData == .update {
                state.displayState.refreshData = .refresh
            } else {
                state.displayState.refreshData = .update
            }
            
            var currentDisplay = state.displayState.currentDisplay

            if state.hasData == false {
                currentDisplay.sections = WalletTypes.DisplayState.Display.skeletonSections(kind: state.displayState.kind)
                currentDisplay.errorState = .none
                currentDisplay.animateType = .refresh(animated: false)
                state.action = .update
            }
            else {
                state.action = .none
            }
            currentDisplay.isRefreshing = true
            state.displayState.currentDisplay = currentDisplay

        case .tapRow(let indexPath):
            state.action = .none

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
            state.action = .update

        case .changeDisplay(let kind):
            state.changeDisplay(state: &state, kind: kind)
            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.isRefreshing = false
            state.displayState.currentDisplay = currentDisplay            
            state.displayState.refreshData = state.hasData ? .none : .refresh
            
            state.action = .none

        case .setAssets(let response):
            
            state.action = .update
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
            state.action = .update

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
            state.action = .none

        case .presentSearch(let startPoint):
            moduleOutput?.presentSearchScreen(from: startPoint, assets: state.assets)
            state.action = .none

        case .updateApp:
            moduleOutput?.openAppStore()
            state.action = .none

        case .isShowCleanWalletBanner(let isShowCleanWalletBanner):
            state.isShowCleanWalletBanner = isShowCleanWalletBanner
            state.action = .none
            
        case .setCleanWalletBanner:
            state.isNeedCleanWalletBanner = true
            state.action = .none

        case .completeCleanWalletBanner:
            state.isShowCleanWalletBanner = false
            state.isNeedCleanWalletBanner = false
            state.action = .none

        case .isHasAppUpdate(let isHasAppUpdate):
            state.isHasAppUpdate = isHasAppUpdate
            state.action = .none
        }
    }

    private static func initialState() -> WalletTypes.State {
        return WalletTypes.State.initialState()
    }
}
