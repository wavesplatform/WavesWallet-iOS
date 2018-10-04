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
}

// MARK: Core State

private extension ProfilePresenter {

    func reduce(state: Types.State, event: Types.Event) -> Types.State {
        return state
    }
}

// MARK: UI State

private extension ProfilePresenter {

    func initialState() -> Types.State {
        return Types.State(displayState: initialDisplayState())
    }

    func initialDisplayState() -> Types.DisplayState {

        let generalSettings = Types.ViewModel.Section(rows: [.addressesKeys, .addressbook, .pushNotifications, .language])

        let security = Types.ViewModel.Section(rows: [.backupPhrase,
                                                      .changePassword,
                                                      .changePasscode,
                                                      .biometric,
                                                      .network])


        let other = Types.ViewModel.Section(rows: [.rateApp,
                                                      .feedback,
                                                      .supportWavesplatform])

        return Types.DisplayState(sections: [generalSettings,
                                             security,
                                             other])
    }
}
