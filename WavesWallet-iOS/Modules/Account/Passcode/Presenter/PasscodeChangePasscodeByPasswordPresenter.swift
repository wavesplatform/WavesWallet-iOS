//
//  NewAccountPasscodePresenter.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RxCocoa
import RxFeedback
import RxSwift

private struct ChangePasscodeByPasswordQuery: Hashable {
    let wallet: Wallet
    let passcode: String
    let password: String
}

final class PasscodeChangePasscodeByPasswordPresenter: PasscodePresenterProtocol {
    fileprivate typealias Types = PasscodeTypes

    private let disposeBag = DisposeBag()

    var interactor: PasscodeInteractorProtocol!
    var input: PasscodeModuleInput!
    weak var moduleOutput: PasscodeModuleOutput?

    func system(feedbacks: [Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(changePasscodeByPassword())
        newFeedbacks.append(logout())

        let initialState = makeInitialSetup(input: input)

        let system = Driver.system(initialState: initialState,
                                   reduce: { [weak self] state, event -> Types.State in
                                       guard let self = self else { return state }
                                       return self.reduce(state: state, event: event)
                                   },
                                   feedback: newFeedbacks)

        system.drive().disposed(by: disposeBag)
    }
}

// MARK: Feedbacks

extension PasscodeChangePasscodeByPasswordPresenter {
    private func changePasscodeByPassword() -> Feedback {
        react(request: { state -> ChangePasscodeByPasswordQuery? in
            if case let .changePasscodeByPassword(wallet, password) = state.kind, case .changePasscodeByPassword = state.action {
                return ChangePasscodeByPasswordQuery(wallet: wallet, passcode: state.passcode, password: password)
            } else {
                return nil
            }
        },
              effects: { [weak self] query -> Signal<Types.Event> in
            guard let self = self else { return Signal.empty() }

            return self
                .interactor
                .changePasscodeByPassword(wallet: query.wallet,
                                          passcode: query.passcode,
                                          password: query.password)
                .map { .completedChangePasscode($0) }
                .asSignal { (error) -> Signal<Types.Event> in .just(.handlerError(error)) }
        })
    }

    private func logout() -> Feedback {
        react(request: { state -> Wallet? in
            if case let .changePasscodeByPassword(wallet, _) = state.kind, case .logout = state.action {
                return wallet
            } else {
                return nil
            }
        },
              effects: { [weak self] wallet -> Signal<Types.Event> in
            guard let self = self else { return Signal.empty() }

            return self
                .interactor.logout(wallet: wallet)
                .map { _ in .completedLogout }
                .asSignal { error -> Signal<Types.Event> in .just(.handlerError(error)) }
        })
    }
}

// MARK: Core State

private extension PasscodeChangePasscodeByPasswordPresenter {
    func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    func reduce(state: inout Types.State, event: Types.Event) {
        switch event {
        case let .completedLogIn(status):
            reduceCompletedLogIn(status: status, state: &state)

        case let .completedChangePasscode(wallet):
            state.action = nil
            state.displayState.isLoading = false
            moduleOutput?.passcodeLogInCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: false)

        case let .handlerError(error):

            state.displayState.isLoading = false
            state.displayState.numbers = []
            state.action = nil
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = Types.displayError(by: error, kind: state.kind)

            if case .biometricLockout? = state.displayState.error {
                state.displayState.isHiddenBiometricButton = true
            }

        case .viewWillAppear:
            break

        case .viewDidAppear:
            break

        case .tapBiometricButton:

            state.displayState.isLoading = true
            state.action = .logInBiometric
            state.displayState.error = nil

        case .tapLogInByPassword:
            moduleOutput?.passcodeLogInByPassword()
            state.displayState.isLoading = false
            state.action = nil
            state.displayState.error = nil

        case .tapLogoutButton:
            state.displayState.isLoading = true
            state.displayState.error = nil
            state.action = .logout

        case .completedLogout:
            state.displayState.isLoading = false
            state.displayState.error = nil
            state.action = nil
            moduleOutput?.passcodeUserLogouted()

        case let .completedInputNumbers(numbers):
            handlerInputNumbersForChangePasscodeByPassword(numbers, state: &state)

        case .tapBack:
            switch state.displayState.kind {
            case .newPasscode:
                moduleOutput?.passcodeTapBackButton()

            case .repeatPasscode:
                state.displayState.kind = .newPasscode
                state.displayState.numbers = []
                state.displayState.isHiddenBackButton = !state.hasBackButton
                state.displayState.error = nil
                state.displayState.titleLabel = state.displayState.kind.title()
            default:
                break
            }
        default:
            break
        }
    }

    // MARK: - Reduce Completed LogIn

    private func reduceCompletedLogIn(status: AuthorizationAuthStatus, state: inout Types.State) {
        switch status {
        case let .completed(wallet):
            state.action = nil
            state.displayState.isLoading = false
            moduleOutput?.passcodeLogInCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: false)

        case .detectBiometric:
            state.displayState.isLoading = false

        case .waiting:
            state.displayState.isLoading = true
        }
    }

    // MARK: - Input Numbers For Chanage Passcode

    private func handlerInputNumbersForChangePasscodeByPassword(_ numbers: [Int], state: inout Types.State) {
        defer {
            state.displayState.titleLabel = state.displayState.kind.title()
        }

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .newPasscode:
            state.displayState.kind = .repeatPasscode
            state.displayState.numbers = []
            state.displayState.isHiddenBackButton = false
            state.displayState.error = nil
            state.passcode = ""

        case .repeatPasscode:
            state.displayState.numbers = numbers
            let newPassword = state.numbers[.newPasscode]

            if let newPassword = newPassword, newPassword == numbers {
                state.displayState.isLoading = true
                state.displayState.isHiddenBackButton = true

                state.passcode = newPassword.reduce(into: "") { $0 += "\($1)" }
                state.action = .changePasscodeByPassword
            } else {
                state.displayState.error = .incorrectPasscode
                state.displayState.isHiddenBackButton = false
                state.displayState.numbers = []
                state.passcode = ""
            }
        default:
            break
        }
    }
}

// MARK: UI State

extension PasscodeChangePasscodeByPasswordPresenter {
    private func makeInitialSetup(input: PasscodeModuleInput) -> Types.State {
        return Types.State(displayState: makeInitialDisplayState(input: input),
                           hasBackButton: input.hasBackButton,
                           kind: input.kind,
                           action: nil,
                           numbers: .init(),
                           passcode: "")
    }

    private func makeInitialDisplayState(input: PasscodeModuleInput) -> Types.DisplayState {
        return .init(kind: .newPasscode,
                     numbers: .init(),
                     isLoading: false,
                     isHiddenBackButton: !input.hasBackButton,
                     isHiddenLogInByPassword: true,
                     isHiddenLogoutButton: input.hasBackButton,
                     isHiddenBiometricButton: true,
                     error: nil,
                     titleLabel: Types.PasscodeKind.newPasscode.title(),
                     detailLabel: nil)
    }
}
