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

    // TODO: Need add Auth or logIn Kind 
    var wallet: DomainLayer.DTO.Wallet { get }
}

protocol AccountPasswordModuleOutput: AnyObject {
    func authorizationByPasswordCompleted(wallet: DomainLayer.DTO.Wallet, password: String)
}

protocol AccountPasswordPresenterProtocol {

    typealias Feedback = (Driver<AccountPasswordTypes.State>) -> Signal<AccountPasswordTypes.Event>

    var interactor: AccountPasswordInteractor! { get set }
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

    var interactor: AccountPasswordInteractor!
    var input: AccountPasswordModuleInput!
    weak var moduleOutput: AccountPasswordModuleOutput?

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(logIn())

        let initialState = self.initialState(wallet: input.wallet)

        let system = Driver.system(initialState: initialState,
                                   reduce: AccountPasswordPresenter.reduce,
                                   feedback: newFeedbacks)

        system
            .map { $0.action }
            .filterNil()
            .drive(onNext: { [weak self] action in
                self?.handlerAction(action: action)
            })
            .disposed(by: disposeBag)
    }

    private func logIn() -> Feedback {
        return react(query: { state -> LogInQuery? in

            if let action = state.action, case .logIn(let password) = action {
                return LogInQuery(wallet: state.wallet, password: password)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .logIn(wallet: query.wallet, password: query.password)
                .map { _ in .completedLogIn }
                .asSignal(onErrorRecover: { (error) -> Signal<Types.Event> in
                    guard let error = error as? AccountPasswordInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }
}

// MARK: Core State

private extension AccountPasswordPresenter {

    func handlerAction(action: Types.State.Action) {
        switch action {
        case .authorizationCompleted(let wallet, let password):
            moduleOutput?.authorizationByPasswordCompleted(wallet: wallet, password: password)

        default:
            break
        }
    }

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {

        switch event {
        case .tapLogIn(let password):
            return state.mutate { state in
                state.action = .logIn(password: password)
                state.password = password
                state.displayState.isLoading = true
            }

        case .completedLogIn:
            return state.mutate { state in
                guard let password = state.password else { return }
                state.action = .authorizationCompleted(state.wallet, password)
                state.displayState.isLoading = false
            }

        case .handlerError(let error):
            //TODO: Error
            return state.mutate { state in
                state.action = nil
                state.displayState.error = .incorrectPassword
                state.displayState.isLoading = false                
            }
        }
    }
}

// MARK: UI State

private extension AccountPasswordPresenter {

    func initialState(wallet: DomainLayer.DTO.Wallet) -> Types.State {
        return Types.State(displayState: initialDisplayState(wallet: wallet),
                           wallet: wallet,
                           action: nil,
                           password: nil)
    }

    func initialDisplayState(wallet: DomainLayer.DTO.Wallet) -> Types.DisplayState {

        return .init(isLoading: false,
                     error: nil,
                     name: wallet.name,
                     address: wallet.address)
    }
}
