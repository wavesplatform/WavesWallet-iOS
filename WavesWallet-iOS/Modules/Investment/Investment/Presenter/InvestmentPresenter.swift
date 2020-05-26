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

final class InvestmentPresenter: InvestmentPresenterProtocol {
    var interactor: InvestmentInteractorProtocol!
    weak var moduleOutput: InvestmentModuleOutput?

    private let disposeBag: DisposeBag = DisposeBag()
    private let kind: InvestmentDisplayState.Kind
    
    private var leasingListener: Signal<InvestmentEvent>?

    init(kind: InvestmentDisplayState.Kind) {
        self.kind = kind
    }

    func system(feedbacks: [Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(queryLeasing())
        newFeedbacks.append(queryLeasingListener())
        newFeedbacks.append(queryStaking())

        Driver
            .system(initialState: InvestmentPresenter.initialState(kind: kind),
                    reduce: { [weak self] state, event -> InvestmentState in
                        self?.reduce(state: state, event: event) ?? state
                    },
                    feedback: newFeedbacks)

            .drive()
            .disposed(by: disposeBag)
    }

    private func queryLeasingListener() -> Feedback {
        return react(request: { (state) -> InvestmentDisplayState.RefreshData? in

            if state.displayState.kind == .leasing {
                return state.displayState.listenerRefreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<InvestmentEvent> in

            guard let self = self else { return Signal.empty() }
            return self.leasingListener?.skip(1) ?? Signal.never()
        })
    }

    private func queryLeasing() -> Feedback {
        return react(request: { (state) -> InvestmentDisplayState.RefreshData? in

            if state.displayState.kind == .leasing, state.displayState.refreshData != .none {
                return state.displayState.refreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<InvestmentEvent> in

            guard let self = self else { return Signal.empty() }
            let listener = self
                .interactor
                .leasing()
                .map { .setLeasing($0) }
                .asSignal(onErrorRecover: { Signal<InvestmentEvent>.just(.handlerError($0)) })

            self.leasingListener = listener
            return listener
        })
    }

    private func queryStaking() -> Feedback {
        return react(request: { (state) -> InvestmentDisplayState.RefreshData? in

            if state.displayState.kind == .staking, state.displayState.refreshData != .none {
                return state.displayState.refreshData
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<InvestmentEvent> in

            guard let self = self else { return Signal.empty() }

            let timer = Observable<Int>
                .timer(0, period: 3.0, scheduler: MainScheduler.instance)
                .take(30)                
                .asSignal(onErrorSignalWith: Signal.just(1))
                .flatMap { _ -> Signal<InvestmentEvent> in
                    self.interactor
                        .staking()
                        .map { .setStaking($0) }
                        .asSignal(onErrorRecover: { Signal<InvestmentEvent>.just(.handlerError($0)) })
                }

            return timer
        })
    }

    private func reduce(state: InvestmentState, event: InvestmentEvent) -> InvestmentState {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    private func resetAnimateType(state: inout InvestmentState) {
        var currentDisplay = state.displayState.currentDisplay
        currentDisplay.animateType = .none
        state.displayState.currentDisplay = currentDisplay
    }

    private func reduce(state: inout InvestmentState, event: InvestmentEvent) {
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
            } else {
                state.action = .none
            }

        case let .completedDepositBalance(balance):

            guard var staking = state.staking else {
                state.action = .none
                return
            }

            state.prevStaking = staking

            var available = staking.balance.available
            var inStaking = staking.balance.inStaking
            var total = staking.balance.total

            SweetLogger.debug("Depost before")
            SweetLogger.debug("Available: \(staking.balance.available.money.amount)")
            SweetLogger.debug("\n InStaking: \(staking.balance.inStaking.money.amount)")
            SweetLogger.debug("\n Total: \(staking.balance.total.money.amount)")

            let availableAmount: Int64 = Int64(max(0, available.money.amount - balance.money.amount))

            available = DomainLayer.DTO.Balance(currency: available.currency,
                                                money: Money(availableAmount,
                                                             available.money.decimals))

            inStaking = DomainLayer.DTO.Balance(currency: inStaking.currency,
                                                money: Money(inStaking.money.amount + balance.money.amount,
                                                             inStaking.money.decimals))

            total = DomainLayer.DTO.Balance(currency: total.currency,
                                            money: Money(available.money.amount + inStaking.money.amount,
                                                         total.money.decimals))

            staking.balance.available = available
            staking.balance.inStaking = inStaking
            staking.balance.total = total

            SweetLogger.debug("Depost after")
            SweetLogger.debug("Available: \(staking.balance.available.money.amount)")
            SweetLogger.debug("\n InStaking: \(staking.balance.inStaking.money.amount)")
            SweetLogger.debug("\n Total: \(staking.balance.total.money.amount)")

            let sections = InvestmentSection.map(from: staking, hasSkingLanding: state.hasSkipLanding)
            state.displayState = state.displayState.updateDisplay(kind: .staking,
                                                                  sections: sections)

            state.staking = staking

            state.action = .update

            if state.displayState.refreshData == .update {
                state.displayState.refreshData = .refresh
            } else {
                state.displayState.refreshData = .update
            }

        case let .completedWithdrawBalance(balance):

            guard var staking = state.staking else {
                state.action = .none
                return
            }

            state.prevStaking = staking

            var available = staking.balance.available
            var inStaking = staking.balance.inStaking
            var total = staking.balance.total

            SweetLogger.debug("Withdraw before")
            SweetLogger.debug("Available: \(staking.balance.available.money.amount)")
            SweetLogger.debug("InStaking: \(staking.balance.inStaking.money.amount)")
            SweetLogger.debug("Total: \(staking.balance.total.money.amount)")

            available = DomainLayer.DTO.Balance(currency: available.currency,
                                                money: Money(available.money.amount + balance.money.amount,
                                                             available.money.decimals))

            let inStakingAmount: Int64 = Int64(max(0, inStaking.money.amount - balance.money.amount))

            inStaking = DomainLayer.DTO.Balance(currency: inStaking.currency,
                                                money: Money(inStakingAmount,
                                                             inStaking.money.decimals))

            total = DomainLayer.DTO.Balance(currency: total.currency,
                                            money: Money(available.money.amount + inStaking.money.amount,
                                                         total.money.decimals))

            staking.balance.available = available
            staking.balance.inStaking = inStaking
            staking.balance.total = total

            SweetLogger.debug("Withdraw after")
            SweetLogger.debug("Available: \(staking.balance.available.money.amount)")
            SweetLogger.debug("InStaking: \(staking.balance.inStaking.money.amount)")
            SweetLogger.debug("Total: \(staking.balance.total.money.amount)")

            let sections = InvestmentSection.map(from: staking, hasSkingLanding: state.hasSkipLanding)
            state.displayState = state.displayState.updateDisplay(kind: .staking,
                                                                  sections: sections)
            state.staking = staking

            state.action = .update

            if state.displayState.refreshData == .update {
                state.displayState.refreshData = .refresh
            } else {
                state.displayState.refreshData = .update
            }

        case .viewDidDisappear:
            state.displayState.isAppeared = false
            state.displayState.leasing.animateType = .none
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
                currentDisplay.sections = InvestmentDisplayState.Display.skeletonSections(kind: state.displayState.kind)
                currentDisplay.errorState = .none
                currentDisplay.animateType = .refresh(animated: false)
                state.action = .update
            } else {
                state.action = .none
            }

            currentDisplay.isRefreshing = true
            // скидываем модель текущую так как обновляем ui если он изменился
            state.staking = nil
            state.prevStaking = nil

            state.displayState.currentDisplay = currentDisplay

        case let .tapRow(indexPath):
            state.action = .none

            let section = state.displayState.currentDisplay.visibleSections[indexPath.section]

            switch section.kind {
            case .balance:
                let row = section.items[indexPath.row]
                if case let .historyCell(type) = row {
                    switch type {
                    case .leasing:
                        moduleOutput?.showHistoryForLeasing()
                    default:
                        break
                    }
                }

            case .transactions:
                let leasingTransactions = section
                    .items
                    .map { $0.leasingTransaction }
                    .compactMap { $0 }
                moduleOutput?.showLeasingTransaction(transactions: leasingTransactions, index: indexPath.row)

            case .staking:
                let row = section.items[indexPath.row]
                if case let .historyCell(type) = row {
                    switch type {
                    case .staking:
                        moduleOutput?.showPayoutsHistory()
                    default:
                        break
                    }
                }

            default:
                break
            }

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

        case let .setLeasing(response):
            state.action = .update

            let sections = InvestmentSection.map(from: response)
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

        case let .setStaking(staking):

            SweetLogger.debug("Update Available: \(staking.balance.available.money.amount)")
            SweetLogger.debug("InStaking: \(staking.balance.inStaking.money.amount)")
            SweetLogger.debug("Total: \(staking.balance.total.money.amount)")

            if let oldStaking = state.staking, oldStaking.balance == staking.balance {
                SweetLogger.debug("Old Staking dismiss")

                state.action = .refreshError
                var currentDisplay = state.displayState.currentDisplay
                currentDisplay.errorState = .none
                currentDisplay.isRefreshing = false
                currentDisplay.animateType = .none
                state.displayState.currentDisplay = currentDisplay
                state.staking = staking
                return
            }

            if let prevStaking = state.prevStaking, prevStaking.balance == staking.balance {
                SweetLogger.debug("Prev Staking dismiss")

                state.action = .refreshError
                var currentDisplay = state.displayState.currentDisplay
                currentDisplay.errorState = .none
                currentDisplay.isRefreshing = false
                currentDisplay.animateType = .none
                state.displayState.currentDisplay = currentDisplay
                state.staking = staking
                return
            }

            state.action = .update

            let sections = InvestmentSection.map(from: staking, hasSkingLanding: state.hasSkipLanding)
            state.displayState = state.displayState.updateDisplay(kind: .staking,
                                                                  sections: sections)
            state.staking = staking
            state.prevStaking = nil

            var currentDisplay = state.displayState.currentDisplay
            currentDisplay.errorState = .none
            currentDisplay.isRefreshing = false
            state.displayState.currentDisplay = currentDisplay

        case let .showStartLease(money):
            moduleOutput?.showStartLease(availableMoney: money)
            state.action = .none

        case .updateApp:
            moduleOutput?.openAppStore()
            state.action = .none


        case let .openStakingFaq(fromLanding):
            moduleOutput?.openStakingFaq(fromLanding: fromLanding)
            state.action = .none

        case .openTrade:
            guard let neutrinoAsset = state.staking?.neutrinoAsset else { return }
            moduleOutput?.openTrade(neutrinoAsset: neutrinoAsset)
            state.action = .none

        case .openBuy:
            guard let neutrinoAsset = state.staking?.neutrinoAsset else { return }
            moduleOutput?.openBuy(neutrinoAsset: neutrinoAsset)
            state.action = .none

        case .openDeposit:
            guard let neutrinoAsset = state.staking?.neutrinoAsset else { return }
            moduleOutput?.openDeposit(neutrinoAsset: neutrinoAsset)
            state.action = .none

        case .openWithdraw:
            guard let neutrinoAsset = state.staking?.neutrinoAsset else { return }
            moduleOutput?.openWithdraw(neutrinoAsset: neutrinoAsset)
            state.action = .none
        
        case let .openFb(text):
            moduleOutput?.openFb(sharedText: text)
            state.action = .none

        case let .openVk(text):
            moduleOutput?.openVk(sharedText: text)
            state.action = .none

        case let .openTw(text):
            moduleOutput?.openTw(sharedText: text)
            state.action = .none

        case .startStaking:
            if let staking = state.staking {
                let sections = InvestmentSection.map(from: staking, hasSkingLanding: true)
                state.displayState = state.displayState.updateDisplay(kind: .staking, sections: sections)

                var value = WalletLandingSetting.value
                value[staking.accountAddress] = true
                WalletLandingSetting.set(value)
            }

            UseCasesFactory
                .instance
                .analyticManager
                .trackEvent(.staking(.landingStart))

            state.hasSkipLanding = true
            state.action = .update
        }
    }

    private static func initialState(kind: InvestmentDisplayState.Kind) -> InvestmentState {
        return InvestmentState.initialState(kind: kind)
    }
}
