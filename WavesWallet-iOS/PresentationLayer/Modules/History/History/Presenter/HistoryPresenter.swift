//
//  HistoryPresenter.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
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
        newFeedbacks.append(queryAll())

        Driver.system(initialState: HistoryPresenter.initialState(historyType: moduleInput.type),
                      reduce: reduce,
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }

    private func queryAll() -> Feedback {
        return react(query: { (state) -> Bool? in

            if state.isAppeared == true {
                if state.isRefreshing {
                    return false
                }
                return true
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<HistoryTypes.Event> in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .interactor
                .transactions(input: strongSelf.moduleInput)
                .map { .responseAll($0) }                
                .asSignal(onErrorRecover: { Signal.just(.handlerError($0)) })
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
            
            state.isAppeared = true

        case .refresh:
            state.isRefreshing = true
            
        case .tapCell(let indexPath):
            
            let item = state.sections[indexPath.section].items[indexPath.item]
            var index = NSNotFound
            
            let filteredTransactions = state.currentFilter.filtered(transactions: state.transactions)
            
            switch item {
            case .transaction(let transaction):
                
                index = filteredTransactions.index(where: { (loopTransaction) -> Bool in
                    return transaction.id == loopTransaction.id
                }) ?? NSNotFound
                
            default:
                break
            }
            
            if (index != NSNotFound) {
                moduleOutput?.showTransaction(transactions: filteredTransactions, index: index)
            }
            


        case .changeFilter(let filter):
            
            let filteredTransactions = filter.filtered(transactions: state.transactions)
            let sections = HistoryTypes.ViewModel.Section.map(from: filteredTransactions)
            state.sections = sections
            state.currentFilter = filter


        case .handlerError:

            state.isRefreshing = false

        case .responseAll(let response):

            let sections = HistoryTypes.ViewModel.Section.map(from: response)
            state.transactions = response
            state.sections = sections
            state.isRefreshing = false
        }
    }

    private static func initialState(historyType: HistoryType) -> HistoryTypes.State {
        return HistoryTypes.State.initialState(historyType: historyType)
    }
}
