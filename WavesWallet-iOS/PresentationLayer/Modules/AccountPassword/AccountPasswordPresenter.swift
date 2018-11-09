//
//  AccountPasswordPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift
import RxOptional

protocol AccountPasswordModuleInput {
    var kind: AccountPasswordTypes.DTO.Kind { get }
}

protocol AccountPasswordModuleOutput: AnyObject {
    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String)
    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String)
}

protocol AccountPasswordPresenterProtocol {

    typealias Feedback = (Driver<AccountPasswordTypes.State>) -> Signal<AccountPasswordTypes.Event>

    var interactor: AccountPasswordInteractorProtocol! { get set }
    var input: AccountPasswordModuleInput! { get set }
    var moduleOutput: AccountPasswordModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

private struct LogInQuery {
    let wallet: DomainLayer.DTO.Wallet
    let password: String
}

final class AccountPasswordPresenter: AccountPasswordPresenterProtocol {

    fileprivate typealias Types = AccountPasswordTypes

    var interactor: AccountPasswordInteractorProtocol!
    var input: AccountPasswordModuleInput!
    weak var moduleOutput: AccountPasswordModuleOutput?

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(logIn())
        newFeedbacks.append(verifyAccess())

        let initialState = self.initialState(kind: input.kind)

        let system = Driver.system(initialState: initialState,
                                   reduce: AccountPasswordPresenter.reduce,
                                   feedback: newFeedbacks)

        system
            .map { $0.query }
            .filterNil()
            .drive(onNext: { [weak self] query in
                self?.handlerQuery(query: query)
            })
            .disposed(by: disposeBag)
    }

    private func logIn() -> Feedback {
        return react(query: { state -> LogInQuery? in

            guard let query = state.query else { return nil }

            if case .logIn(let wallet, let password) = query {
                return LogInQuery(wallet: wallet, password: password)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .logIn(wallet: query.wallet, password: query.password)
                .map { .completedLogIn($0, password: query.password) }
                .asSignal(onErrorRecover: { error -> Signal<Types.Event> in
                    guard let error = error as? AccountPasswordInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }

    private func verifyAccess() -> Feedback {
        return react(query: { state -> LogInQuery? in

            guard let query = state.query else { return nil }

            if case .verifyAccess(let wallet, let password) = query {
                return LogInQuery(wallet: wallet, password: password)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .verifyAccess(wallet: query.wallet, password: query.password)
                .map { .completedVerifyAccess($0, password: query.password) }
                .asSignal(onErrorRecover: { error -> Signal<Types.Event> in
                    guard let error = error as? AccountPasswordInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }
}

// MARK: Core State

private extension AccountPasswordPresenter {

    func handlerQuery(query: Types.State.Query) {
        switch query {
        case .authorizationCompleted(let wallet, let password):
            moduleOutput?.accountPasswordAuthorizationCompleted(wallet: wallet, password: password)

        case .verifyAccessCompleted(let wallet, let password):
            moduleOutput?.accountPasswordVerifyAccess(signedWallet: wallet, password: password)

        default:
            break
        }
    }

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {

        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    static func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .tapLogIn(let password):

            switch state.kind {
            case .logIn(let wallet):
                state.query = .logIn(wallet: wallet, password: password)

            case .verifyAccess(let wallet):
                state.query = .verifyAccess(wallet: wallet, password: password)
            }

            state.displayState.isLoading = true

        case .completedLogIn(let wallet, let password):
            state.query = .authorizationCompleted(wallet, password)
            state.displayState.isLoading = false

        case .completedVerifyAccess(let wallet, let password):
            state.query = .verifyAccessCompleted(wallet, password)
            state.displayState.isLoading = false

        case .handlerError(let error):
            //TODO: Error
            state.query = nil
            state.displayState.error = .incorrectPassword
            state.displayState.isLoading = false

        }
    }
}

// MARK: UI State

private extension AccountPasswordPresenter {

    func initialState(kind: AccountPasswordTypes.DTO.Kind) -> Types.State {
        return Types.State(displayState: initialDisplayState(kind: kind),
                           kind: kind,
                           query: nil)
    }

    func initialDisplayState(kind: AccountPasswordTypes.DTO.Kind) -> Types.DisplayState {

        switch kind {
        case .logIn(let wallet):
            return .init(isLoading: false,
                         error: nil,
                         name: wallet.name,
                         address: wallet.address)

        case .verifyAccess(let wallet):
            return .init(isLoading: false,
                         error: nil,
                         name: wallet.name,
                         address: wallet.address)
        }
    }
}
