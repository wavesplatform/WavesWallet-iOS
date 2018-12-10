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

private struct SetEnableBiometricQuery: Hashable {
    let wallet: DomainLayer.DTO.Wallet
    let passcode: String
    let isOn: Bool
}

final class PasscodeEnableBiometricPresenter: PasscodePresenterProtocol {

    fileprivate typealias Types = PasscodeTypes

    private let disposeBag: DisposeBag = DisposeBag()

    var interactor: PasscodeInteractorProtocol!
    var input: PasscodeModuleInput!
    weak var moduleOutput: PasscodeModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(changeEnableBiometric())
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

extension PasscodeEnableBiometricPresenter {

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
                    return Signal.just(.handlerError(error))
            }
        })
    }

    private struct LogoutQuery: Hashable {
        let wallet: DomainLayer.DTO.Wallet
    }

    private func logout() -> Feedback {
        return react(query: { state -> LogoutQuery? in

            if case .setEnableBiometric(_, let wallet) = state.kind,
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

private extension PasscodeEnableBiometricPresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {

        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    func reduce(state: inout Types.State, event: Types.Event) {

        switch event {
        case .completedLogIn(let status):
            reduceCompletedLogIn(status: status, state: &state)

        case .handlerError(let error):

            state.displayState.isLoading = false
            state.displayState.numbers = []
            state.action = nil
            state.displayState.error = .incorrectPasscode
            state.displayState.isHiddenBackButton = !state.hasBackButton
            state.displayState.error = Types.displayError(by: error, kind: state.kind)

        case .viewWillAppear:
            break
            
        case .viewDidAppear:

            state.action = .disabledBiometricUsingBiometric
            state.displayState.error = nil

        case .tapBiometricButton:

            state.displayState.isLoading = true
            state.action = .disabledBiometricUsingBiometric
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

            switch state.kind {
            case .setEnableBiometric(let isOn, let wallet):
                handlerInputNumbersForChangeBiometric(numbers, state: &state, isOnBiomentric: isOn, wallet: wallet)

            default:
                break
            }

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

            switch state.kind {
            case .changePasscode:

                state.displayState.kind = .newPasscode
                state.displayState.numbers = []
                state.displayState.titleLabel = state.displayState.kind.title()

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

private extension PasscodeEnableBiometricPresenter {

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
                         isHiddenBiometricButton: true,
                         error: nil,
                         titleLabel: Types.PasscodeKind.enterPasscode.title(),
                         detailLabel: nil)

        default:
            return .init(kind: .newPasscode,
                         numbers: .init(),
                         isLoading: false,
                         isHiddenBackButton: !input.hasBackButton,
                         isHiddenLogInByPassword: true,
                         isHiddenLogoutButton: true,
                         isHiddenBiometricButton: true,
                         error: nil,
                         titleLabel: "",
                         detailLabel: nil)
        }
    }
}
