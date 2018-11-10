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

private struct RegistationQuery: Hashable {
    let account: PasscodeTypes.DTO.Account
    let passcode: String
}

private struct LogInQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let passcode: String
}

private struct LogoutQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
}

private struct SetEnableBiometricQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let passcode: String
    let isOn: Bool
}

private struct ChangePasscodeQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let passcode: String
    let oldPasscode: String
}

private struct ChangePasscodeByPasswordQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let passcode: String
    let password: String
}

private struct ChangePasswordQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let passcode: String
    let oldPassword: String
    let newPassword: String
}

final class PasscodePresenter: PasscodePresenterProtocol {

    fileprivate typealias Types = PasscodeTypes

    private let disposeBag: DisposeBag = DisposeBag()

    var interactor: PasscodeInteractorProtocol!
    var input: PasscodeModuleInput!
    weak var moduleOutput: PasscodeModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(registration())
        newFeedbacks.append(logIn())
        newFeedbacks.append(logout())
        newFeedbacks.append(logInBiometric())
        newFeedbacks.append(changeEnableBiometric())
        newFeedbacks.append(disabledBiometricUsingBiometric())
        newFeedbacks.append(changePasscode())
        newFeedbacks.append(changePasscodeByPassword())
        newFeedbacks.append(verifyAccessBiometric())
        newFeedbacks.append(verifyAccess())
        newFeedbacks.append(changePassword())

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

extension PasscodePresenter {

    private func changePassword() -> Feedback {
        return react(query: { state -> ChangePasswordQuery? in

            if case .changePassword(let wallet, let newPassword, let oldPassword) = state.kind,
                let action = state.action,
                case .changePassword = action {
                return ChangePasswordQuery(wallet: wallet, passcode: state.passcode, oldPassword: oldPassword, newPassword: newPassword)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .changePassword(wallet: query.wallet, passcode: query.passcode, oldPassword: query.oldPassword, newPassword: query.newPassword)
                .map { .completedChangePassword($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
            }
        })
    }


    private func changePasscodeByPassword() -> Feedback {
        return react(query: { state -> ChangePasscodeByPasswordQuery? in

            if case .changePasscodeByPassword(let wallet, let password) = state.kind, let action = state.action, case .changePasscodeByPassword = action {
                return ChangePasscodeByPasswordQuery(wallet: wallet, passcode: state.passcode, password: password)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .changePasscodeByPassword(wallet: query.wallet,
                                          passcode: query.passcode,
                                          password: query.password)
                .map { .completedChangePasscode($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func changePasscode() -> Feedback {
        return react(query: { state -> ChangePasscodeQuery? in

            if case .changePasscode(let wallet) = state.kind, let action = state.action, case .changePasscode(let oldPasscode) = action {
                return ChangePasscodeQuery(wallet: wallet, passcode: state.passcode, oldPasscode: oldPasscode)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .changePasscode(wallet: query.wallet,
                                oldPasscode: query.oldPasscode,
                                passcode: query.passcode)
                .map { .completedChangePasscode($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func registration() -> Feedback {
        return react(query: { state -> RegistationQuery? in

            if case .registration(let account) = state.kind, let action = state.action, case .registration = action {
                return RegistationQuery(account: account, passcode: state.passcode)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .registrationAccount(query.account,
                                     passcode: query.passcode)
                .map { .completedRegistration($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func disabledBiometricUsingBiometric() -> Feedback {
        return react(query: { state -> DomainLayer.DTO.Wallet? in

            if case .setEnableBiometric(_, let wallet) = state.kind,
                let action = state.action,
                case .disabledBiometricUsingBiometric = action {
                return wallet
            }

            return nil

        }, effects: { [weak self] wallet -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .disabledBiometricUsingBiometric(wallet: wallet)
                .sweetDebug("Biometric")
                .map { Types.Event.completedLogIn($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func changeEnableBiometric() -> Feedback {
        return react(query: { state -> SetEnableBiometricQuery? in

            if case .setEnableBiometric(let isOn, let wallet) = state.kind,
                let action = state.action, case .setEnableBiometric = action {
                return SetEnableBiometricQuery(wallet: wallet, passcode: state.passcode, isOn: isOn)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .setEnableBiometric(wallet: query.wallet, passcode: query.passcode, isOn: query.isOn)
                .sweetDebug("Biometric")
                .map { Types.Event.completedLogIn($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func logInBiometric() -> Feedback {
        return react(query: { state -> LogInByBiometricQuery? in

            if case .logIn(let wallet) = state.kind, let action = state.action, case .logInBiometric = action {
                return LogInByBiometricQuery(wallet: wallet)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .logInBiometric(wallet: query.wallet)
                .sweetDebug("Biometric")
                .map { Types.Event.completedLogIn($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func verifyAccess() -> Feedback {
        return react(query: { state -> LogInQuery? in

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
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
            }
        })
    }

    private func verifyAccessBiometric() -> Feedback {
        return react(query: { state -> LogInByBiometricQuery? in

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
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
            }
        })
    }

    private func logIn() -> Feedback {
        return react(query: { state -> LogInQuery? in

            if let action = state.action, case .logIn = action {
                if case .logIn(let wallet) = state.kind {
                    return LogInQuery(wallet: wallet, passcode: state.passcode)
                }
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .logIn(wallet: query.wallet, passcode: query.passcode)
                .sweetDebug("Passcode")
                .map { Types.Event.completedLogIn($0) }
                .asSignal { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }

    private func logout() -> Feedback {
        return react(query: { state -> LogoutQuery? in

            if case .logIn(let wallet) = state.kind,
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
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                }
        })
    }
}

// MARK: Core State

private extension PasscodePresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {

        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .completedLogIn(let status):
            reduceCompletedLogIn(status: status, state: &state)

        case .completedChangePassword(let wallet):
            state.action = nil
            state.displayState.isLoading = false
            moduleOutput?.passcodeLogInCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: false)

        case .completedChangePasscode(let wallet):
            state.action = nil
            state.displayState.isLoading = false
            moduleOutput?.passcodeLogInCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: false)

        case .completedVerifyAccess(let status):
            reduceCompletedVerifyAccess(status: status, state: &state)

        case .completedRegistration(let status):

            switch status {
            case .completed(let wallet):
                moduleOutput?.passcodeLogInCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: true)
                state.action = nil

            case .detectBiometric:
                state.displayState.isLoading = false

            case .waiting:
                state.displayState.isLoading = true
            }

        case .handlerError(let error):

            state.displayState.isLoading = false
            state.displayState.numbers = []
            state.action = nil
            state.displayState.error = .incorrectPasscode
            state.displayState.isHiddenBackButton = !state.hasBackButton

        //   TODO: Error
        //            switch error {
        //            case .attemptsEnded:
        //            case .passcodeIncorrect:
        //            case .passwordIncorrect:
        //            case .permissionDenied:
        //            case .fail:
        //            }

        case .viewWillAppear:
            break
        case .viewDidAppear:

            switch state.kind {
            case .logIn(let wallet) where wallet.hasBiometricEntrance == true:
                state.action = .logInBiometric
                state.displayState.error = nil

            case .setEnableBiometric(_, let wallet) where wallet.hasBiometricEntrance == true:
                state.action = .disabledBiometricUsingBiometric
                state.displayState.error = nil

            case .verifyAccess(let wallet) where wallet.hasBiometricEntrance == true:
                state.action = .verifyAccessBiometric
                state.displayState.error = nil
                
            default:
                break
            }

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

        case .completedInputNumbers(let numbers):
            reduceInputNumbers(numbers, state: &state)

        case .tapBack:
            reduceTapBack(state: &state)
        }
    }

    // MARK: - Reduce Completed LogIn

    private func reduceCompletedVerifyAccess(status: AuthorizationVerifyAccessStatus, state: inout Types.State) {

        switch status {
        case .completed(let wallet):

            state.action = nil
            state.displayState.isLoading = false

            switch state.kind {
            case .changePasscode:

                state.displayState.kind = .newPasscode
                state.displayState.numbers = []
                state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)

            default:
                moduleOutput?.passcodeVerifyAccessCompleted(wallet)
            }

        case .detectBiometric:
            state.displayState.isLoading = false

        case .waiting:
            state.displayState.isLoading = true
        }
    }

    // MARK: - Reduce Completed LogIn

    private func reduceCompletedLogIn(status: AuthorizationAuthStatus, state: inout Types.State) {

        switch status {
        case .completed(let wallet):
            state.action = nil
            state.displayState.isLoading = false
            moduleOutput?.passcodeLogInCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: false)

        case .detectBiometric:
            state.displayState.isLoading = false

        case .waiting:
            state.displayState.isLoading = true
        }
    }

    // MARK: - Reduce Tap Bcak

    private func reduceTapBack(state: inout Types.State) {

        switch state.kind {

        case .logIn,
             .setEnableBiometric,
             .verifyAccess,
             .changePassword:
            moduleOutput?.passcodeTapBackButton()

        case .changePasscodeByPassword:
            switch state.displayState.kind {
            case .newPasscode:
                moduleOutput?.passcodeTapBackButton()

            case .repeatPasscode:
                state.displayState.kind = .newPasscode
                state.displayState.numbers = []
                state.displayState.isHiddenBackButton = !state.hasBackButton
                state.displayState.error = nil
                state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)
            default:
                break
            }

        case .changePasscode:
            switch state.displayState.kind {
            case .oldPasscode:
                moduleOutput?.passcodeTapBackButton()

            case .newPasscode:
                state.displayState.kind = .oldPasscode
                state.displayState.numbers = []
                state.displayState.isHiddenBackButton = !state.hasBackButton
                state.displayState.error = nil
                state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)

            case .repeatPasscode:
                state.displayState.kind = .newPasscode
                state.displayState.numbers = []
                state.displayState.isHiddenBackButton = !state.hasBackButton
                state.displayState.error = nil
                state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)
            default:
                break
            }

        case .registration:
            state.displayState.kind = .newPasscode
            state.displayState.numbers = []
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = nil
            state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)
        }
    }

    // MARK: - Handler Inputs

    private func reduceInputNumbers(_ numbers: [Int], state: inout Types.State) {

        switch state.kind {

        case .changePassword:
            handlerInputNumbersForChangePassword(numbers, state: &state)

        case .changePasscodeByPassword:
            handlerInputNumbersForChangePasscodeByPassword(numbers, state: &state)

        case .changePasscode:
            handlerInputNumbersForChangePasscode(numbers, state: &state)

        case .logIn:
            handlerInputNumbersForLogIn(numbers, state: &state)

        case .verifyAccess:
            handlerInputNumbersForVerifyAccess(numbers, state: &state)

        case .registration:
            handlerInputNumbersForRegistration(numbers, state: &state)

        case .setEnableBiometric(let isOn, let wallet):
            handlerInputNumbersForChangeBiometric(numbers, state: &state, isOnBiomentric: isOn, wallet: wallet)
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

    // MARK: - Input Numbers For Chanage Passcode

    private func handlerInputNumbersForChangePasscodeByPassword(_ numbers: [Int], state: inout Types.State) {

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

            if let newPassword = newPassword,
                newPassword == numbers {

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

        defer {
            state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)
        }
    }

    // MARK: - Input Numbers For Chanage Passcode

    private func handlerInputNumbersForChangePasscode(_ numbers: [Int], state: inout Types.State) {

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .oldPasscode:
            let oldPasscode = state.numbers[.oldPasscode]
            state.displayState.isLoading = true
            state.displayState.error = nil
            state.passcode = oldPasscode.reduce(into: "") { $0 += "\($1)" }
            state.action = .verifyAccess

        case .newPasscode:
            state.displayState.kind = .repeatPasscode
            state.displayState.numbers = []
            state.displayState.isHiddenBackButton = false
            state.displayState.error = nil
            state.passcode = ""

        case .repeatPasscode:
            state.displayState.numbers = numbers
            let newPassword = state.numbers[.newPasscode]
            let oldPasscode = state.numbers[.oldPasscode]

            if let newPassword = newPassword,
                let oldPasscode = oldPasscode,
                newPassword == numbers {

                state.displayState.isLoading = true
                state.displayState.isHiddenBackButton = true

                let oldPasscode = oldPasscode.reduce(into: "") { $0 += "\($1)" }
                state.passcode = newPassword.reduce(into: "") { $0 += "\($1)" }
                state.action = .changePasscode(oldPasscode: oldPasscode)
            } else {
                state.displayState.error = .incorrectPasscode
                state.displayState.isHiddenBackButton = false
                state.displayState.numbers = []
                state.passcode = ""
            }
        default:
            break
        }

        defer {
            state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)
        }
    }

    // MARK: - Input Numbers For Registration

    private func handlerInputNumbersForRegistration(_ numbers: [Int], state: inout Types.State) {

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
                state.action = .registration
                state.passcode = newPassword.reduce(into: "") { $0 += "\($1)" }
            } else {
                state.displayState.error = .incorrectPasscode
                state.displayState.isHiddenBackButton = false
                state.displayState.numbers = []
                state.passcode = ""
            }
        default:
            break
        }

        defer {
            state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)
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

    // MARK: - Input Numbers For Log In

    private func handlerInputNumbersForLogIn(_ numbers: [Int], state: inout Types.State) {

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .enterPasscode:
            state.displayState.isLoading = true
            state.displayState.numbers = numbers
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = nil
            state.passcode = numbers.reduce(into: "") { $0 += "\($1)" }
            state.action = .logIn
        default:
            break
        }
    }

    // MARK: - Input Numbers For Change Biometric

    private func handlerInputNumbersForChangeBiometric(_ numbers: [Int],
                                                       state: inout Types.State,
                                                       isOnBiomentric: Bool,
                                                       wallet: DomainLayer.DTO.Wallet) {

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .enterPasscode:
            state.displayState.isLoading = true
            state.displayState.numbers = numbers
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = nil
            state.passcode = numbers.reduce(into: "") { $0 += "\($1)" }
            state.action = .setEnableBiometric
        default:
            break
        }
    }
}

// MARK: UI State

private extension PasscodePresenter {

    func initialState(input: PasscodeModuleInput) -> Types.State {
        return Types.State(displayState: initialDisplayState(input: input),
                           hasBackButton: input.hasBackButton,
                           kind: input.kind,
                           action: nil,
                           numbers: .init(),
                           passcode: "")
    }

    func isHiddenLogInByPassword(input: PasscodeModuleInput) -> Bool {
        switch input.kind {

        case .changePasscodeByPassword,
             .setEnableBiometric,
             .registration,
             .changePassword:
            return true

        case .logIn,
             .changePasscode,
             .verifyAccess:
            return false
        }
    }

    func initialDisplayState(input: PasscodeModuleInput) -> Types.DisplayState {

        switch input.kind {

        case .changePassword:
            return .init(kind: .enterPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: isHiddenLogInByPassword(input: input),
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: true,
                         error: nil,
                         titleLabel: input.kind.title(kind: .enterPasscode),
                         detailLabel: nil)

        case .changePasscodeByPassword:
            return .init(kind: .newPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: isHiddenLogInByPassword(input: input),
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: true,
                         error: nil,
                         titleLabel: input.kind.title(kind: .newPasscode),
                         detailLabel: nil)

        case .changePasscode:
            return .init(kind: .oldPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: isHiddenLogInByPassword(input: input),
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: true,
                         error: nil,
                         titleLabel: input.kind.title(kind: .oldPasscode),
                         detailLabel: nil)

        case .setEnableBiometric(_, let wallet):
            return .init(kind: .enterPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: isHiddenLogInByPassword(input: input),
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: !wallet.hasBiometricEntrance,
                         error: nil,
                         titleLabel: input.kind.title(kind: .enterPasscode),
                         detailLabel: nil)

        case .verifyAccess(let wallet):
            return .init(kind: .enterPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: isHiddenLogInByPassword(input: input),
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: !wallet.hasBiometricEntrance,
                         error: nil,
                         titleLabel: input.kind.title(kind: .enterPasscode),
                         detailLabel: wallet.address)

        case .logIn(let wallet):
            return .init(kind: .enterPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: isHiddenLogInByPassword(input: input),
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: !wallet.hasBiometricEntrance,
                         error: nil,
                         titleLabel: input.kind.title(kind: .enterPasscode),
                         detailLabel: wallet.address)

        case .registration:
            return .init(kind: .newPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: isHiddenLogInByPassword(input: input),
                         isHiddenLogoutButton: true,
                         isHiddenBiometricButton: true,
                         error: nil,
                         titleLabel: input.kind.title(kind: .newPasscode),
                         detailLabel: nil)
        }
    }
}

fileprivate extension PasscodeTypes.DTO.Kind {

    func title(kind: PasscodeTypes.PasscodeKind) -> String {

        switch self {

        case .logIn(let wallet):
            return wallet.name

        case .verifyAccess(let wallet):
            return wallet.name

        default:
            switch kind {
            case .oldPasscode:
                return Localizable.Waves.Passcode.Label.Passcode.enter

            case .newPasscode:
                return Localizable.Waves.Passcode.Label.Passcode.create

            case .repeatPasscode:
                return Localizable.Waves.Passcode.Label.Passcode.verify

            case .enterPasscode:
                return Localizable.Waves.Passcode.Label.Passcode.enter
            }
        }
    }
}
