//
//  ChooseAccountPresenter.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

protocol ChooseAccountModuleOutput: AnyObject {
    func userChooseAccount(wallet: DomainLayer.DTO.Wallet, passcodeNotCreated: Bool) -> Void
    func userEditAccount(wallet: DomainLayer.DTO.Wallet) -> Void
}

protocol ChooseAccountModuleInput {
}

protocol ChooseAccountPresenterProtocol {

    typealias Feedback = (Driver<ChooseAccountTypes.State>) -> Signal<ChooseAccountTypes.Event>

    var input: ChooseAccountModuleInput! { get set }
    var moduleOutput: ChooseAccountModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

private struct DeleteWalletQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let indexPath: IndexPath
}

final class ChooseAccountPresenter: ChooseAccountPresenterProtocol {

    fileprivate typealias Types = ChooseAccountTypes
    
    var input: ChooseAccountModuleInput!
    weak var moduleOutput: ChooseAccountModuleOutput?

    private let authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(walletsFeedback())
        newFeedbacks.append(removeWallet())
        newFeedbacks.append(hasPermissionQuery())

        let initialState = self.initialState()
        let system = Driver.system(initialState: initialState,
                                   reduce: { [weak self] state, event -> Types.State in
                                       self?.reduce(state: state, event: event) ?? state
                                   },
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }

    private func walletsFeedback() -> Feedback {
        return react(request: { state -> Bool? in
            state.isAppeared == true ? true : nil
        }, effects: { [weak self] _ -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .authorizationInteractor
                .wallets()
                .map { Types.Event.setWallets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func removeWallet() -> Feedback {
        return react(request: { state -> DeleteWalletQuery? in
            if let action = state.action, case .removeWallet(let wallet, let indexPath) = action {
                return DeleteWalletQuery(wallet: wallet, indexPath: indexPath)
            }

            return nil
        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .authorizationInteractor
                .deleteWallet(query.wallet)
                .map { _ in Types.Event.completedDeleteWallet(indexPath: query.indexPath) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func hasPermissionQuery() -> Feedback {
        return react(request: { state -> DomainLayer.DTO.Wallet? in
            if let action = state.action, case .openWallet(let wallet) = action {
                return wallet
            }

            return nil
        }, effects: { [weak self] wallet -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .authorizationInteractor
                .hasPermissionToLoggedIn(wallet)
                .map { _ in Types.Event.openWallet(wallet, passcodeNotCreated: false) }
                .asSignal(onErrorRecover: { error -> Signal<Types.Event> in
                    if case AuthorizationInteractorError.passcodeNotCreated? = error as? AuthorizationInteractorError {
                        return Signal.just(Types.Event.openWallet(wallet, passcodeNotCreated: true))
                    }
                    return Signal.never()
                })
        })
    }
}

// MARK: Core State

private extension ChooseAccountPresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    func reduce(state: inout Types.State, event: Types.Event) {
        switch event {
        case .readyView:
            state.isAppeared = true
            state.displayState.action = .none

        case .viewDidDisappear:
            state.displayState.action = .none
            state.isAppeared = false

        case .setWallets(let wallets):
            state.displayState.wallets = wallets
            state.displayState.action = .reload

        case .tapWallet(let wallet):
            state.action = .openWallet(wallet)
            state.displayState.action = .none

        case .tapRemoveButton(let wallet, let indexPath):
            state.displayState.action = .none
            state.action = .removeWallet(wallet, indexPath: indexPath)

        case .openWallet(let wallet, let passcodeNotCreated):
            state.action = nil
            state.displayState.action = .none
            moduleOutput?.userChooseAccount(wallet: wallet, passcodeNotCreated: passcodeNotCreated)
            
        case .completedDeleteWallet(let indexPath):

            state.action = nil
            var wallets = state.displayState.wallets
            wallets.remove(at: indexPath.row)
            state.displayState.wallets = wallets
            state.displayState.action = .remove(indexPath: indexPath)

        case .tapEditButton(let wallet, let indexPath):
            moduleOutput?.userEditAccount(wallet: wallet)
            state.displayState.action = .none
            state.action = .editWallet(wallet, indexPath: indexPath)
        }
    }
}

// MARK: UI State

private extension ChooseAccountPresenter {

    func initialState() -> Types.State {
        return Types.State(displayState: initialDisplayState(), action: nil, isAppeared: false)
    }

    func initialDisplayState() -> Types.DisplayState {
        return Types.DisplayState(wallets: [], action: .none)
    }
    
}
