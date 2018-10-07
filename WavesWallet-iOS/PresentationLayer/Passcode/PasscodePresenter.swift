//
//  NewAccountPasscodePresenter.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxFeedback

protocol PasscodeModuleOutput: AnyObject {
    func authorizationCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) -> Void
    func userLogouted()
    func logInByPassword()
    func tapBackButton()
}

protocol PasscodeModuleInput {
    var kind: PasscodeTypes.DTO.Kind { get }
    var hasBackButton: Bool { get }
}

protocol PasscodePresenterProtocol {

    typealias Feedback = (Driver<PasscodeTypes.State>) -> Signal<PasscodeTypes.Event>

    var interactor: PasscodeInteractorProtocol! { get set }
    var input: PasscodeModuleInput! { get set }
    var moduleOutput: PasscodeModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

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

        let initialState = self.initialState(input: input)

        let system = Driver.system(initialState: initialState,
                                   reduce: { [weak self] state, event -> Types.State in
                                       self?.reduce(state: state, event: event) ?? state
                                   }, feedback: newFeedbacks)

        system
            .drive()
            .disposed(by: disposeBag)
    }

    private func registration() -> Feedback {
        return react(query: { state -> RegistationQuery? in

            if case let  .registration(account) = state.kind, let action = state.action, case .registration =  action {
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
                .asSignal(onErrorRecover: { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }

    private func changeEnableBiometric() -> Feedback {
        return react(query: { state -> SetEnableBiometricQuery? in

            if case let .setEnableBiometric(isOn, wallet) = state.kind,
                let action = state.action,
                case .setEnableBiometric =  action {
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
                .asSignal(onErrorRecover: { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }

    private func logInBiometric() -> Feedback {
        return react(query: { state -> LogInByBiometricQuery? in

            if case let .logIn(wallet) = state.kind, let action = state.action, case .logInBiometric =  action {
                return LogInByBiometricQuery(wallet: wallet)
            } else if case let .setEnableBiometric(_, wallet) = state.kind,
                let action = state.action,
                case .logInBiometric = action {
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
                .asSignal(onErrorRecover: { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }

    private func logIn() -> Feedback {
        return react(query: { state -> LogInQuery? in

            if case let .logIn(wallet) = state.kind, let action = state.action, case .logIn =  action {
                return LogInQuery(wallet: wallet, passcode: state.passcode)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor
                .logIn(wallet: query.wallet, passcode: query.passcode)
                .sweetDebug("Passcode")
                .map { Types.Event.completedLogIn($0) }
                .asSignal(onErrorRecover: { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }

    private func logout() -> Feedback {
        return react(query: { state -> LogoutQuery? in

            if case let .logIn(wallet) = state.kind,
                let action = state.action, case .logout = action {
                return LogoutQuery(wallet: wallet)
            }

            return nil

        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor.logout(wallet: query.wallet)
                .map { _ in .completedLogout }
                .asSignal(onErrorRecover: { (error) -> Signal<Types.Event> in
                    guard let error = error as? PasscodeInteractorError else { return Signal.just(.handlerError(.fail)) }
                    return Signal.just(.handlerError(error))
                })
        })
    }
}

// MARK: Core State

private extension PasscodePresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {

        switch event {
        case .completedLogIn(let wallet):

            self.moduleOutput?.authorizationCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: false)
            return state.mutate(transform: { state in
                state.action = nil
            })

        case .completedRegistration(let wallet):

            self.moduleOutput?.authorizationCompleted(passcode: state.passcode, wallet: wallet, isNewWallet: true)
            return state.mutate(transform: { state in
                state.action = nil
            })

        case .handlerError(let error):

            return state.mutate(transform: { state in
                state.displayState.isLoading = false
                state.displayState.numbers = []
                state.action = nil
                state.displayState.error = .incorrectPasscode
            })
//   TODO: Error
//            switch error {
//            case .attemptsEnded:
//            case .passcodeIncorrect:
//            case .passwordIncorrect:
//            case .permissionDenied:
//            case .fail:
//            }
        case .viewDidAppear:
            return state.mutate { state in
                if case .logIn(let wallet) = state.kind, wallet.hasBiometricEntrance {
                    state.displayState.isLoading = true
                    state.action = .logInBiometric
                    state.displayState.error = nil
                } else if case .setEnableBiometric(_, let wallet) = state.kind, wallet.hasBiometricEntrance {
                    state.displayState.isLoading = true
                    state.action = .logInBiometric
                    state.displayState.error = nil
                }
            }

        case .tapBiometricButton:
            return state.mutate { state in
                state.displayState.isLoading = true
                state.action = .logInBiometric
                state.displayState.error = nil
            }

        case .tapLogInByPassword:
            moduleOutput?.logInByPassword()
            return state.mutate { state in
                state.displayState.isLoading = false
                state.action = nil
                state.displayState.error = nil
            }

        case .tapLogoutButton:

            return state.mutate { state in
                state.displayState.isLoading = true
                state.action = .logout
            }

        case .completedLogout:
            moduleOutput?.userLogouted()
            return state

        case .completedInputNumbers(let numbers):
            return state.mutate { state in
                handlerInputNumbers(numbers, state: &state)
            }

        case .tapBack:

            switch state.kind {
            case .logIn, .setEnableBiometric:
                moduleOutput?.tapBackButton()
                return state

            case .registration:
                return state.mutate { state in
                    state.displayState.kind = .newPasscode
                    state.displayState.numbers = []
                    state.displayState.isHiddenBackButton = !state.hasBackButton
                    state.displayState.error = nil
                    state.displayState.titleLabel = state.kind.title(kind: state.displayState.kind)
                }
            }
        }
        return state
    }

    private func handlerInputNumbers(_ numbers: [Int], state: inout Types.State)  {

        switch state.kind {
        case .logIn:
            handlerInputNumbersForLogIn(numbers, state: &state)

        case .registration:
            handlerInputNumbersForRegistration(numbers, state: &state)

        case .setEnableBiometric(let isOn, let wallet):
            handlerInputNumbersForChangeBiometric(numbers, state: &state, isOnBiomentric: isOn, wallet: wallet)
        }
    }


    private func handlerInputNumbersForRegistration(_ numbers: [Int], state: inout Types.State)  {

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
                state.passcode = newPassword.reduce(into: "", { $0 += "\($1)" })
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

    private func handlerInputNumbersForLogIn(_ numbers: [Int], state: inout Types.State)  {

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .enterPasscode:
            state.displayState.isLoading = true
            state.displayState.numbers = numbers
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = nil
            state.passcode = numbers.reduce(into: "", { $0 += "\($1)" })
            state.action = .logIn
        default:
            break
        }
    }

    private func handlerInputNumbersForChangeBiometric(_ numbers: [Int],
                                                       state: inout Types.State,
                                                       isOnBiomentric: Bool, wallet: DomainLayer.DTO.Wallet)  {

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .enterPasscode:
            state.displayState.isLoading = true
            state.displayState.numbers = numbers
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = nil
            state.passcode = numbers.reduce(into: "", { $0 += "\($1)" })
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

    func initialDisplayState(input: PasscodeModuleInput) -> Types.DisplayState {

        switch input.kind {
        case .setEnableBiometric(_, let wallet):
            return .init(kind: .enterPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: true,
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: !wallet.hasBiometricEntrance,
                         error: nil,
                         titleLabel: input.kind.title(kind: .enterPasscode),
                         detailLabel: nil)

        case .logIn(let wallet):
            return .init(kind: .enterPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: false,
                         isHiddenLogoutButton: input.hasBackButton,
                         isHiddenBiometricButton: !wallet.hasBiometricEntrance,
                         error: nil,
                         titleLabel: input.kind.title(kind: .newPasscode),
                         detailLabel: wallet.address)

        case .registration:
            return .init(kind: .newPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: true,
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
        case .setEnableBiometric(_, let wallet):
            return  Localizable.Passcode.Label.Passcode.enter

        case .logIn(let wallet):
            return wallet.name

        case .registration:
            switch kind {
            case .newPasscode:
                return  Localizable.Passcode.Label.Passcode.create

            case .repeatPasscode:
                return  Localizable.Passcode.Label.Passcode.verify

            case .enterPasscode:
                return  Localizable.Passcode.Label.Passcode.enter
            }
        }
    }
}

