//
//  ProfilePresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol ProfileModuleInput {

}

protocol ProfileModuleOutput: AnyObject {

}

protocol ProfilePresenterProtocol {

    typealias Feedback = (Driver<ProfileTypes.State>) -> Signal<ProfileTypes.Event>

//    var interactor: PasscodeInteractor! { get set }
//    var input: ProfileModuleInput! { get set }
    var moduleOutput: ProfileModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

//BlockRepositoryRemote
final class ProfilePresenter: ProfilePresenterProtocol {

    fileprivate typealias Types = ProfileTypes

    private let disposeBag: DisposeBag = DisposeBag()

//    var interactor: PasscodeInteractor!
//    var input: ProfileModuleInput!
    weak var moduleOutput: ProfileModuleOutput?

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks

        let initialState = self.initialState()

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
}

// MARK: Core State

private extension ProfilePresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {

        switch event {
        case .viewDidAppear:
            break

        case .tapRow(let row):
            break

        case .setEnabledBiometric(let isOn):
            break

        case .tapLogout:
            break

        case .tapDelete:
            break
        }
        return state
    }
}

// MARK: UI State

private extension ProfilePresenter {

    func initialState() -> Types.State {
        return Types.State(displayState: initialDisplayState())
    }

    func initialDisplayState() -> Types.DisplayState {

        let generalSettings = Types.ViewModel.Section(rows: [.addressesKeys,
                                                             .addressbook,
                                                             .pushNotifications,
                                                             .language(Language.currentLanguage)], kind: .general)

        let security = Types.ViewModel.Section(rows: [.backupPhrase(isBackedUp: true),
                                                      .changePassword,
                                                      .changePasscode,
                                                      .biometric(isOn: true),
                                                      .network], kind: .security)

        let other = Types.ViewModel.Section(rows: [.rateApp,
                                                   .feedback,
                                                   .supportWavesplatform,
                                                   .info(version: "2.0.2 (13)", height: nil)], kind: .other)

        return Types.DisplayState(sections: [generalSettings,
                                             security,
                                             other])
    }
}
