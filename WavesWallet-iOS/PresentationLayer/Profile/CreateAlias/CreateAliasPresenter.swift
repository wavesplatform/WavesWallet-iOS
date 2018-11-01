//
//  CreateAliasPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol CreateAliasModuleOutput: AnyObject {
    func createAliasCompletedCreateAlias(_ alias: String)
}

protocol CreateAliasModuleInput {}

protocol CreateAliasPresenterProtocol {

    typealias Feedback = (Driver<CreateAliasTypes.State>) -> Signal<CreateAliasTypes.Event>

    var moduleOutput: CreateAliasModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

final class CreateAliasPresenter: CreateAliasPresenterProtocol {

    fileprivate typealias Types = CreateAliasTypes

    private let disposeBag: DisposeBag = DisposeBag()
    private let aliasesRepository: AliasesRepositoryProtocol = FactoryRepositories.instance.aliasesRepository
    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let transactionsInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    weak var moduleOutput: CreateAliasModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(checkExistAliasQuery())
        newFeedbacks.append(getAliasesQuery())
        newFeedbacks.append(externalQueries())

        let initialState = self.initialState()

        let system = Driver.system(initialState: initialState,
                                   reduce: CreateAliasPresenter.reduce,
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - Feedbacks

fileprivate extension CreateAliasPresenter {

    func externalQueries() -> Feedback {

        return react(query: { state -> Types.Query? in

            switch state.query {
            case .completedCreateAlias?:
                return state.query
            default:
                return nil
            }

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            if case .completedCreateAlias(let name) = query {
                strongSelf.moduleOutput?.createAliasCompletedCreateAlias(name)
            }

            return Signal.just(.completedQuery)
        })
    }

    func getAliasesQuery() -> Feedback {

        return react(query: { state -> String? in

            if case .createAlias(let name)? = state.query {
                return name
            } else {
                return nil
            }

        }, effects: { [weak self] name -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .authorizationInteractor
                .authorizedWallet()
                .flatMap({ wallet -> Observable<Bool> in
                    return strongSelf
                        .transactionsInteractor
                        .send(by: .createAlias(.init(alias: name, fee: GlobalConstants.WavesTransactionFeeAmount)), wallet: wallet)
                        .map { _ in true }
                })
                .map { _ in .aliasCreated }
                .asSignal(onErrorRecover: { e in
                    error(e)
                    return Signal.just(Types.Event.handlerError(e))
                })
        })
    }


    func checkExistAliasQuery() -> Feedback {

        return react(query: { state -> String? in

            if case .checkExist(let name)? = state.query {
                return name
            } else {
                return nil
            }

        }, effects: { [weak self] name -> Signal<Types.Event> in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .authorizationInteractor
                .authorizedWallet()
                .flatMap({ wallet -> Observable<String> in
                    return strongSelf.aliasesRepository.alias(by: name, accountAddress: wallet.wallet.address)
                })
                .sweetDebug("Debug")
                .map { _ in .errorAliasExist }
                .asSignal(onErrorRecover: { e in
                    error(e)
                    return Signal.just(Types.Event.aliasAameFree)
                })
        })
    }
}

// MARK: Core State

private extension CreateAliasPresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .viewWillAppear:
            state.displayState.isAppeared = true
            let section = Types.ViewModel.Section(rows: [.input(state.displayState.input, error: nil)])
            state.displayState.sections = [section]
            state.displayState.action = .reload

        case .viewDidDisappear:
            state.displayState.isAppeared = false

        case .input(let text):
            state.displayState.input = text
            state.displayState.action = .none
            state.query = nil

            if let text = text {
                if RegEx.alias(text) {
                    if text.count < GlobalConstants.aliasNameMinLimitSymbols {
                        state.displayState.isEnabledSaveButton = false
                        state.displayState.error = "Minimum 4 characters"
                    } else if text.count > GlobalConstants.aliasNameMaxLimitSymbols {
                        state.displayState.isEnabledSaveButton = false
                        state.displayState.error = "30 characters maximum"
                    } else {
                        state.displayState.isLoading = true
                        state.displayState.isEnabledSaveButton = false
                        state.displayState.error = nil
                        state.query = .checkExist(text)
                    }
                } else {
                    state.displayState.error = "Invalid character"
                    state.displayState.isEnabledSaveButton = false
                }
            } else {
                state.displayState.error = nil
                state.displayState.isEnabledSaveButton = false
            }

            state.displayState.action = .update
            let section = Types.ViewModel.Section(rows: [.input(state.displayState.input, error: state.displayState.error)])
            state.displayState.sections = [section]

        case .aliasAameFree:
            state.query = nil
            state.displayState.error = nil
            state.displayState.action = .update
            state.displayState.isLoading = false
            state.displayState.isEnabledSaveButton = true
            let section = Types.ViewModel.Section(rows: [.input(state.displayState.input, error: state.displayState.error)])
            state.displayState.sections = [section]

        case .errorAliasExist:
            state.query = nil
            state.displayState.error = "Already in use"
            state.displayState.action = .update
            state.displayState.isLoading = false            
            let section = Types.ViewModel.Section(rows: [.input(state.displayState.input, error: state.displayState.error)])
            state.displayState.sections = [section]

        case .handlerError:
            state.query = nil
            state.displayState.isLoading = false
            // TODO:

        case .aliasCreated:
            guard let text = state.displayState.input else { return }
            state.displayState.isLoading = false
            state.query = .completedCreateAlias(text)

        case .createAlias:
            guard let text = state.displayState.input else { return }
            state.query = .createAlias(text)
            state.displayState.isLoading = true

        case .completedQuery:
            state.query = nil
        }
    }
}

// MARK: UI State

private extension CreateAliasPresenter {

    func initialState() -> Types.State {
        return Types.State(query: nil,
                           displayState: initialDisplayState())
    }

    func initialDisplayState() -> Types.DisplayState {

        return Types.DisplayState(sections: [],
                                  input: nil,
                                  error: nil,
                                  isEnabledSaveButton: false,
                                  isLoading: false,
                                  isAppeared: false,
                                  action: .none)
    }
}

