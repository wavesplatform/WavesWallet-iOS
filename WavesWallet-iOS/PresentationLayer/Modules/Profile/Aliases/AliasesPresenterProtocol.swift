//
//  AliasesViewPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol AliasesModuleOutput: AnyObject {
    func aliasesCreateAlias()
}

protocol AliasesModuleInput {
    var aliases: [DomainLayer.DTO.Alias] { get }
}

protocol AliasesPresenterProtocol {

    typealias Feedback = (Driver<AliasesTypes.State>) -> Signal<AliasesTypes.Event>

    var moduleOutput: AliasesModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

final class AliasesPresenter: AliasesPresenterProtocol {

    fileprivate typealias Types = AliasesTypes

    private let disposeBag: DisposeBag = DisposeBag()

    private let transactionsInteractor = FactoryInteractors.instance.transactions
    private let authorizationInteractor = FactoryInteractors.instance.authorization

    var moduleInput: AliasesModuleInput!
    weak var moduleOutput: AliasesModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(createAliasQuery())
        newFeedbacks.append(initialAliasQuery())

        let initialState = self.initialState(moduleInput: moduleInput)

        let system = Driver.system(initialState: initialState,
                                   reduce: AliasesPresenter.reduce,
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - Feedbacks

fileprivate extension AliasesPresenter {

    func createAliasQuery() -> Feedback {

        return react(query: { state -> Types.Query? in

            if case .createAlias? = state.query {
                return state.query
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<Types.Event> in
            self?.moduleOutput?.aliasesCreateAlias()
            return Signal.just(.completedQuery)
        })
    }

    func initialAliasQuery() -> Feedback {

        return react(query: { state -> Types.Query? in

            if case .calculateFee? = state.query {
                return state.query
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<Types.Event> in

            guard let owner = self else { return Signal.never() }

            return owner
                .authorizationInteractor
                .authorizedWallet()
                .flatMap({ [weak self] (wallet) -> Observable<Money> in
                    guard let owner = self else { return Observable.never() }
                    return owner.transactionsInteractor.calculateFee(by: .createAlias, accountAddress: wallet.address)
                })
                .map { .setFee($0) }
                .asSignal(onErrorRecover: { Signal.just(.handlerError($0)) })
        })
    }
}

// MARK: Core State

private extension AliasesPresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .viewWillAppear:
            state.displayState.isAppeared = true
            state.query = .calculateFee
            state.displayState.transactionFee = .progress
            state.displayState.isEnabledCreateAliasButton = false

        case .tapCreateAlias:
            state.query = .createAlias

        case .handlerError(let error):
            state.query = nil
            state.displayState.error = DisplayError(error: error)
            state.displayState.isEnabledCreateAliasButton = false
            state.displayState.transactionFee = .progress

        case .setFee(let money):
            state.query = nil
            state.displayState.isEnabledCreateAliasButton = true
            state.displayState.transactionFee = .fee(money)
            state.displayState.error = nil

        case .completedQuery:
            state.query = nil
        }
    }
}

// MARK: UI State

private extension AliasesPresenter {

    func initialState(moduleInput: AliasesModuleInput) -> Types.State {
        return Types.State(aliaces: moduleInput.aliases,
                           query: nil,
                           displayState: initialDisplayState(moduleInput: moduleInput))
    }

    func initialDisplayState(moduleInput: AliasesModuleInput) -> Types.DisplayState {

        var rows: [Types.ViewModel.Row] = [.head]

        for alias in moduleInput.aliases {
            rows.append(.alias(alias))
        }

        let section = Types.ViewModel.Section(rows: rows)

        return Types.DisplayState(sections: [section],
                                  isAppeared: false,
                                  action: .update,
                                  error: nil,
                                  transactionFee: .progress,
                                  isEnabledCreateAliasButton: false)
    }
}
