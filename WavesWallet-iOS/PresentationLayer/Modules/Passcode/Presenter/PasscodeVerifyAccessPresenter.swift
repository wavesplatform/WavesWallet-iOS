//
//  NewAccountPasscodePresenter.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

private struct LogInByBiometricQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
}

private struct LogInQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let passcode: String
}

final class PasscodeVerifyAccessPresenter: PasscodePresenterProtocol {

    fileprivate typealias Types = PasscodeTypes

    private let disposeBag: DisposeBag = DisposeBag()

    var interactor: PasscodeInteractorProtocol!
    var input: PasscodeModuleInput!
    weak var moduleOutput: PasscodeModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(verifyAccessBiometric())
        newFeedbacks.append(verifyAccess())
        newFeedbacks.append(logout())

        let initialState = self.initialState(input: input)

        let system = Driver.system(initialState: initialState,
                                   reduce: { [weak self] state, event -> Types.State in
                                    self?.reduce(state: state, event: event) ?? state
            },
                                   feedback: newFeedbacks)

        system
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: Feedbacks

extension PasscodeVerifyAccessPresenter {

    private func verifyAccess() -> Feedback {
        return react(request: { state -> LogInQuery? in

            if let action = state.action, case .verifyAccess = action {
                if case .verifyAccess(let wallet) = state.kind {
                    return LogInQuery(wallet: wallet, passcode: state.passcode)

                } else if case .changePasscode(let wallet) = state.kind {
                    return LogInQuery(wallet: wallet, passcode: state.passcode)
                }
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .verifyAccess(wallet: query.wallet, passcode: query.passcode)
                .map { Types.Event.completedVerifyAccess($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    return Signal.just(.handlerError(error))
            }
        })
    }

    private func verifyAccessBiometric() -> Feedback {
        return react(request: { state -> LogInByBiometricQuery? in

            if let action = state.action, case .verifyAccessBiometric = action {
                if case .verifyAccess(let wallet) = state.kind {
                    return LogInByBiometricQuery(wallet: wallet)
                }
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .verifyAccessUsingBiometric(wallet: query.wallet)
                .map { Types.Event.completedVerifyAccess($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    return Signal.just(.handlerError(error))
            }
        })
    }

    private struct LogoutQuery: Hashable {
        let wallet: DomainLayer.DTO.Wallet
    }

    private func logout() -> Feedback {
        return react(request: { state -> LogoutQuery? in

            if case .verifyAccess(let wallet) = state.kind,
                let action = state.action, case .logout = action {
                return LogoutQuery(wallet: wallet)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor.logout(wallet: query.wallet)
                .map { _ in .completedLogout }
                .asSignal { (error) -> Signal<Types.Event> in
                    return Signal.just(.handlerError(error))
            }
        })
    }
}

// MARK: Core State

private extension PasscodeVerifyAccessPresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {

        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    func reduce(state: inout Types.State, event: Types.Event) {

        switch event {

        case .completedVerifyAccess(let status):
            reduceCompletedVerifyAccess(status: status, state: &state)

        case .handlerError(let error):

            state.displayState.isLoading = false
            state.displayState.numbers = []
            state.action = nil
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = Types.displayError(by: error, kind: state.kind)
            if  case .biometricLockout? = state.displayState.error {
                state.displayState.isHiddenBiometricButton = true
            }

        case .viewWillAppear:
            break
            
        case .viewDidAppear:

            state.displayState.error = nil
            
            switch state.kind {
            case .verifyAccess(let wallet) where wallet.hasBiometricEntrance == true:

                if BiometricType.enabledBiometric != .none {
                    state.action = .verifyAccessBiometric
                    state.displayState.isHiddenBiometricButton = false
                } else {
                    state.action = nil
                    state.displayState.isHiddenBiometricButton = true
                }

            default:
                state.action = nil
                state.displayState.isHiddenBiometricButton = true
            }

        case .tapBiometricButton:

            state.displayState.isLoading = true
            state.action = .verifyAccessBiometric
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

        case .completedInputNumbers(let numbers):
            handlerInputNumbersForVerifyAccess(numbers, state: &state)

        case .tapBack:
            moduleOutput?.passcodeTapBackButton()

        default:
            break
        }
    }

    // MARK: - Reduce Completed LogIn

    private func reduceCompletedVerifyAccess(status: AuthorizationVerifyAccessStatus, state: inout Types.State) {

        switch status {
        case .completed(let wallet):
            state.action = nil
            state.displayState.isLoading = false
            moduleOutput?.passcodeVerifyAccessCompleted(wallet)

        case .detectBiometric:
            state.displayState.isLoading = false

        case .waiting:
            state.displayState.isLoading = true
        }
    }

    // MARK: - Input Numbers For Verify Access

    private func handlerInputNumbersForVerifyAccess(_ numbers: [Int], state: inout Types.State) {

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .enterPasscode:
            state.displayState.isLoading = true
            state.displayState.numbers = numbers
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = nil
            state.passcode = numbers.reduce(into: "") { $0 += "\($1)" }
            state.action = .verifyAccess
        default:
            break
        }
    }
}

// MARK: UI State

private extension PasscodeVerifyAccessPresenter {

    func initialState(input: PasscodeModuleInput) -> Types.State {
        return Types.State(displayState: initialDisplayState(input: input),
                           hasBackButton: input.hasBackButton,
                           kind: input.kind,
                           action: nil,
                           numbers: .init(),
                           passcode: "")
    }

    func initialDisplayState(input: PasscodeModuleInput) -> Types.DisplayState {

        switch input.kind {

        case .verifyAccess(let wallet):
            return .init(kind: .enterPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: false,
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: !wallet.hasBiometricEntrance,
                         error: nil,
                         titleLabel: wallet.name,
                         detailLabel: wallet.address)

        default:
            return .init(kind: .newPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: false,
                         isHiddenLogInByPassword: false,
                         isHiddenLogoutButton: true,
                         isHiddenBiometricButton: true,
                         error: nil,
                         titleLabel: "",
                         detailLabel: nil)
        }
    }
}
