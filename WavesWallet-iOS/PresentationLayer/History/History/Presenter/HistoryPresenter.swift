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
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func reduce(state: HistoryTypes.State, event: HistoryTypes.Event) -> HistoryTypes.State {
        switch event {
        case .readyView:
            return state.setIsAppeared(true)

        case .refresh:
            interactor.refreshTransactions()
            return state.setIsRefreshing(true)

            
        case .tapCell(let indexPath):
            
            let item = state.sections[indexPath.section].items[indexPath.item]
            var index = NSNotFound
            
            switch item {
            case .transaction(let transaction):
                index = state.transactions.index(where: { (loopTransaction) -> Bool in
                    return transaction.id == loopTransaction.id
                }) ?? NSNotFound
            default: break
            }
            
            if (index != NSNotFound) {
                moduleOutput?.showTransaction(transactions: state.transactions, index: index)
            }
            
            return state

        case .changeFilter(let filter):
            let sections = HistoryTypes.ViewModel.Section.filter(from: state.transactions, filter: filter)
            let newState = state.setSections(sections: sections).setFilter(filter: filter)
            return newState

        case .responseAll(let response):

            let sections = HistoryTypes.ViewModel.Section.map(from: response)
            let newState = state
                .setTransactions(transactions: response)
                .setFilter(filter: .all)
                .setSections(sections: sections)
                .setIsRefreshing(false)

            return newState
        }
    }

    private static func initialState(historyType: HistoryType) -> HistoryTypes.State {
        return HistoryTypes.State.initialState(historyType: historyType)
    }
}
