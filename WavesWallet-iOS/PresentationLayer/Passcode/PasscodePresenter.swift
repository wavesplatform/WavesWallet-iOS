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

protocol PasscodeOutput: AnyObject {
    
}

protocol PasscodeInput {
    var kind: PasscodeTypes.DTO.Kind { get }
}

protocol PasscodePresenterProtocol {

    typealias Feedback = (Driver<PasscodeTypes.State>) -> Signal<PasscodeTypes.Event>

    var interactor: PasscodeInteractor! { get set }
    var input: PasscodeInput! { get set }
    var moduleOutput: PasscodeOutput? { get set }

    func system(feedbacks: [Feedback])
}

final class PasscodePresenter: PasscodePresenterProtocol {

    private struct RegistationQuery: Hashable {
        let account: Types.DTO.Account
        let passcode: [Int]
    }

    fileprivate typealias Types = PasscodeTypes

    private let disposeBag: DisposeBag = DisposeBag()

    var interactor: PasscodeInteractor!
    var input: PasscodeInput!
    var moduleOutput: PasscodeOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(registration())

        let initialState = self.initialState(kind: input!.kind)

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

            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf
                .interactor.registrationAccount(query.account,
                                                passcode: query.passcode)
                .map { _ in .completedRegistration }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
}

// MARK: Core State

private extension PasscodePresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {

        switch event {
        case .completedRegistration:

            return state.mutate(transform: { state in
                state.action = nil
            })

        case .completedInputNumbers(let numbers):
            return state.mutate { state in
                handlerInputNumbers(numbers, state: &state)
            }

        case .tapBack:
            return state.mutate { state in
                state.displayState.kind = .newPassword
                state.displayState.numbers =  state.numbers[.newPassword]  ?? []
                state.displayState.isHiddenBackButton = true
            }
        }
    }

    private func handlerInputNumbers(_ numbers: [Int], state: inout Types.State)  {

        let kind = state.displayState.kind
        state.numbers[kind] = numbers

        switch kind {
        case .newPassword:
            state.displayState.kind = .repeatPassword
            state.displayState.numbers = []
            state.displayState.isHiddenBackButton = false
            state.displayState.error = nil

        case .repeatPassword:
            state.displayState.numbers = numbers
            let newPassword = state.numbers[.newPassword]
            if let newPassword = newPassword, newPassword == numbers {
                state.displayState.isLoading = true
                state.displayState.isHiddenBackButton = true
                state.action = .registration
            } else {
                state.displayState.error = .incorrectPasscode
                state.displayState.isHiddenBackButton = false
            }
        }
    }
}

// MARK: UI State

private extension PasscodePresenter {

    func initialState(kind: PasscodeTypes.DTO.Kind) -> Types.State {
        return Types.State(displayState: initialDisplayState(), kind: kind, action: nil, numbers: .init(), passcode: .init())
    }

    func initialDisplayState() -> Types.DisplayState {
        return .init(kind: .newPassword, numbers: .init(), isLoading: false, isHiddenBackButton: true, error: nil)
    }
}
