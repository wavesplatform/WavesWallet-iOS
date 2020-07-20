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

private struct ChangePasswordQuery: Hashable {
    let wallet: Wallet
    let passcode: String
    let oldPassword: String
    let newPassword: String
}

final class PasscodeChangePasswordPresenter: PasscodePresenterProtocol {
    fileprivate typealias Types = PasscodeTypes

    private let disposeBag = DisposeBag()

    var interactor: PasscodeInteractorProtocol!
    var input: PasscodeModuleInput!
    weak var moduleOutput: PasscodeModuleOutput?

    func system(feedbacks: [Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(changePassword())
        newFeedbacks.append(logout())

        let initialState = makeInitialState(input: input)

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

extension PasscodeChangePasswordPresenter {
    private func changePassword() -> Feedback {
        react(request: { state -> ChangePasswordQuery? in
            if case let .changePassword(wallet, newPassword, oldPassword) = state.kind, case .changePassword = state.action {
                return ChangePasswordQuery(wallet: wallet,
                                           passcode: state.passcode,
                                           oldPassword: oldPassword,
                                           newPassword: newPassword)
            } else {
                return nil
            }
        },
              effects: { [weak self] query -> Signal<Types.Event> in

            guard let self = self else { return .empty() }

            return self
                .interactor
                .changePassword(wallet: query.wallet, passcode: query.passcode, oldPassword: query.oldPassword,
                                newPassword: query.newPassword)
                .map { .completedChangePassword($0) }
                .asSignal { error -> Signal<Types.Event> in .just(.handlerError(error)) }
        })
    }

    private func logout() -> Feedback {
        react(request: { state -> Wallet? in

            if case let .changePassword(wallet, _, _) = state.kind, case .logout = state.action {
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

private extension PasscodeChangePasswordPresenter {
    func reduce(state: Types.State, event: Types.Event) -> Types.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    func reduce(state: inout Types.State, event: Types.Event) {
        switch event {
        case let .completedChangePassword(wallet):
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
            handlerInputNumbersForChangePassword(numbers, state: &state)

        case .tapBack:
            moduleOutput?.passcodeTapBackButton()

        default:
            break
        }
    }

    // MARK: - Input Numbers For Change Password

    private func handlerInputNumbersForChangePassword(_ numbers: [Int], state: inout Types.State) {
        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .enterPasscode:
            state.displayState.isLoading = true
            state.displayState.numbers = numbers
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = nil
            state.passcode = numbers.reduce(into: "") { $0 += "\($1)" }
            state.action = .changePassword
        default:
            break
        }
    }
}

// MARK: UI State

extension PasscodeChangePasswordPresenter {
    private func makeInitialState(input: PasscodeModuleInput) -> Types.State {
        Types.State(displayState: makeInitialDisplayState(input: input),
                    hasBackButton: input.hasBackButton,
                    kind: input.kind,
                    action: nil,
                    numbers: .init(),
                    passcode: "")
    }

    private func makeInitialDisplayState(input: PasscodeModuleInput) -> Types.DisplayState {
        .init(kind: .enterPasscode,
              numbers: .init(),
              isLoading: false,
              isHiddenBackButton: !input.hasBackButton,
              isHiddenLogInByPassword: true,
              isHiddenLogoutButton: true,
              isHiddenBiometricButton: true,
              error: nil,
              titleLabel: Types.PasscodeKind.enterPasscode.title(),
              detailLabel: nil)
    }
}
