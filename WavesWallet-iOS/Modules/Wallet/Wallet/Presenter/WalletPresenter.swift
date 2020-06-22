//
//  WalletsViewModel.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import RxFeedback
import RxSwift
import WavesSDK
import WavesSDKExtensions

final class WalletPresenter: WalletPresenterProtocol {
    var interactor: WalletInteractorProtocol!

    private let disposeBag: DisposeBag = DisposeBag()
    private let kind: WalletDisplayState.Kind

    private var assetListener: Signal<WalletEvent>?

    init(kind: WalletDisplayState.Kind) {
        self.kind = kind
    }

    func system(feedbacks: [Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(queryAssets())
        newFeedbacks.append(queryAssetsListener())
        newFeedbacks.append(queryAppUpdate())

        Driver
            .system(initialState: WalletPresenter.initialState(kind: kind),
                    reduce: { [weak self] state, event -> WalletState in
                        self?.reduce(state: state, event: event) ?? state
                    },
                    feedback: newFeedbacks)

            .drive()
            .disposed(by: disposeBag)
    }

    private func queryAppUpdate() -> Feedback {
        return react(request: { (_) -> Bool? in
            true

        }, effects: { [weak self] _ -> Signal<WalletEvent> in

            guard let self = self else { return Signal.empty() }
            return self.interactor.isHasAppUpdate().map { .isHasAppUpdate($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func queryAssets() -> Feedback {
        return react(request: { (state) -> WalletDisplayState.RefreshData? in

            if state.displayState.kind == .assets, state.displayState.refreshData != .none {
                return state.displayState.refreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletEvent> in

            guard let self = self else { return Signal.empty() }
            let signal = self
                .interactor
                .assets()
                .map { .setAssets($0) }
                .asSignal(onErrorRecover: { Signal<WalletEvent>.just(.handlerError($0)) })

            self.assetListener = signal
            return signal
        })
    }

    private func queryAssetsListener() -> Feedback {
        return react(request: { (state) -> WalletDisplayState.RefreshData? in

            if state.displayState.kind == .assets {
                return state.displayState.listenerRefreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletEvent> in

            guard let self = self else { return Signal.empty() }
            return self.assetListener?.skip(1) ?? Signal.never()
        })
    }

    private func reduce(state: WalletState, event: WalletEvent) -> WalletState {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    private func resetAnimateType(state: inout WalletState) {
        var currentDisplay = state.displayState.currentDisplay
        currentDisplay.animateType = .none
        state.displayState.currentDisplay = currentDisplay
    }

    private func reduce(state: inout WalletState, event: WalletEvent) {
        resetAnimateType(state: &state)

        switch event {
        case .viewDidAppear:
            state.displayState.isAppeared = true
            state.displayState.refreshData = .refresh

            if state.hasData == false {
                var currentDisplay = state.displayState.currentDisplay
                currentDisplay.animateType = .refresh(animated: false)
                state.displayState.currentDisplay = currentDisplay
                state.action = .update
            } else {
                state.action = .none
            }

        case .viewDidDisappear:
            state.displayState.isAppeared = false
            state.displayState.assets.animateType = .none
            state.displayState.refreshData = .none
            state.action = .none

        case let .handlerError(error):

            state.displayState = state.displayState.setIsRefreshing(isRefreshing: false)
            state.displayState.refreshData = .none

            var currentDisplay = state.displayState.currentDisplay

            if error is NetworkError {
                // Приходит ошибки из авторизации что доступ запрещен, когда пользователь сворачивает приложение
                let errorStatus = DisplayErrorState.displayErrorState(hasData: state.hasData, error: error)
                currentDisplay.errorState = errorStatus
            } else {
                currentDisplay.errorState = .none
            }

            currentDisplay.animateType = .refreshOnlyError
            state.displayState.currentDisplay = currentDisplay
            state.action = .update

        case .refresh:
            if state.displayState.refreshData == .update {
                state.displayState.refreshData = .refresh
            } else {
                state.displayState.refreshData = .update
            }

            var currentDisplay = state.displayState.currentDisplay

            if state.hasData == false {
                currentDisplay.sections = WalletDisplayState.Display.skeletonSections(kind: state.displayState.kind)
                currentDisplay.errorState = .none
                currentDisplay.animateType = .refresh(animated: false)
                state.action = .update
            } else {
                state.action = .none
            }

            currentDisplay.isRefreshing = true
            // скидываем модель текущую так как обновляем ui если он изменился

            state.displayState.currentDisplay = currentDisplay

        case let .tapSection(section):
            state.displayState = state.displayState.toggleCollapse(index: section)
            state.action = .update

        case let .changeDisplay(kind):
            state.changeDisplay(state: &state, kind: kind)
            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.isRefreshing = false
            state.displayState.currentDisplay = currentDisplay
            state.displayState.refreshData = state.hasData ? state.displayState.refreshData : .refresh

            state.action = .none

        case let .setAssets(response):

            state.action = .update
            let sections = WalletSectionVM.map(from: response)
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

        case let .isHasAppUpdate(isHasAppUpdate):
            state.isHasAppUpdate = isHasAppUpdate
            state.action = .none
        }
    }

    private static func initialState(kind: WalletDisplayState.Kind) -> WalletState {
        return WalletState.initialState(kind: kind)
    }
}
