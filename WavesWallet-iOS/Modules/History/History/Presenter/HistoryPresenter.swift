//
//  HistoryPresenter.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

protocol HistoryPresenterProtocol {
    typealias Feedback = (Driver<HistoryTypes.State>) -> Signal<HistoryTypes.Event>

    func system(feedbacks: [Feedback])
}

final class HistoryPresenter: HistoryPresenterProtocol {
    var interactor: HistoryInteractorProtocol!
    weak var moduleOutput: HistoryModuleOutput?
    let moduleInput: HistoryModuleInput

    private let disposeBag: DisposeBag = DisposeBag()

    init(input: HistoryModuleInput) {
        moduleInput = input
    }

    func system(feedbacks: [Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(queryRefresh())

        Driver.system(initialState: HistoryPresenter.initialState(historyType: moduleInput.type),
                      reduce: reduce,
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }

    private func queryRefresh() -> Feedback {
        return react(request: { (state) -> HistoryTypes.RefreshData? in

            state.refreshData
        }, effects: { [weak self] _ -> Signal<HistoryTypes.Event> in
            guard let self = self else { return Signal.empty() }
            return self
                .interactor
                .transactions(input: self.moduleInput)
                .map { .responseAll($0) }
                .asSignal(onErrorRecover: { _ in
                    Signal.empty()
                })
        })
    }

    private func reduce(state: HistoryTypes.State, event: HistoryTypes.Event) -> HistoryTypes.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    private func reduce(state: inout HistoryTypes.State, event: HistoryTypes.Event) {
        switch event {
        case .readyView:
            if state.refreshData == .update {
                state.refreshData = .refresh
            } else {
                state.refreshData = .update
            }
            state.isAppeared = true

        case .viewDidDisappear:
            state.isAppeared = false

        case .refresh:

            state.isRefreshing = true
            if state.refreshData == .update {
                state.refreshData = .refresh
            } else {
                state.refreshData = .update
            }

            switch state.errorState {
            case let .error(error):

                switch error {
                case .globalError:
                    state.errorState = .none
                    state.sections = HistoryTypes.State.skeletonSections()

                default:
                    state.errorState = .waiting
                }

            default:
                break
            }

        case let .tapCell(indexPath):

            let item = state.sections[indexPath.section].items[indexPath.item]
            var index = NSNotFound

            let filteredTransactions = state.currentFilter.filtered(transactions: state.transactions)

            switch item {
            case let .transaction(transaction):

                index = filteredTransactions.firstIndex(where: { (loopTransaction) -> Bool in
                    transaction.id == loopTransaction.id
                }) ?? NSNotFound

            default:
                break
            }

            if index != NSNotFound {
                moduleOutput?.showTransaction(transaction: filteredTransactions[index])
            }

        case let .changeFilter(filter):

            let filteredTransactions = filter.filtered(transactions: state.transactions)
            let sections = HistoryTypes.ViewModel.Section.map(from: filteredTransactions)
            state.sections = sections
            state.currentFilter = filter

        case let .responseAll(response):

            state.isRefreshing = false

            if let response = response.resultIngoreError {
                let filteredTransactions = state.currentFilter.filtered(transactions: response)
                let sections = HistoryTypes.ViewModel.Section.map(from: filteredTransactions)
                state.sections = sections
                state.transactions = response
            }

            if let error = response.anyError {
                let hasTransactions = (response.resultIngoreError?.count ?? 0) > 0
                state.errorState = DisplayErrorState.displayErrorState(hasData: hasTransactions, error: error)
                state.refreshData = nil
            } else {
                state.errorState = .none
            }
        }
    }

    private static func initialState(historyType: HistoryType) -> HistoryTypes.State {
        return HistoryTypes.State.initialState(historyType: historyType)
    }
}
