//
//  PasscodePresenterProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06/11/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import RxCocoa
import RxFeedback
import RxSwift

protocol PasscodeModuleOutput: AnyObject {
    // TODO: Its method incorect name, becase many flow (for example: LogIn & ChangePassword)
    func passcodeLogInCompleted(passcode: String, wallet: Wallet, isNewWallet: Bool) -> Void
    func passcodeVerifyAccessCompleted(_ wallet: SignedWallet) -> Void

    func passcodeUserLogouted()
    func passcodeLogInByPassword()
    func passcodeTapBackButton()
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
