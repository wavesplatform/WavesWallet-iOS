//
//  ChooseAccountPresenter.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxFeedback

protocol ChooseAccountModuleOutput: AnyObject {
}

protocol ChooseAccountModuleInput {

}

protocol PasscodePresenterProtocol {

    typealias Feedback = (Driver<PasscodeTypes.State>) -> Signal<PasscodeTypes.Event>

    var interactor: PasscodeInteractor! { get set }
    var input: PasscodeModuleInput! { get set }
    var moduleOutput: PasscodeModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

final class ChooseAccountPresenter: PasscodePresenterProtocol {

    var interactor: PasscodeInteractor!
    var input: PasscodeModuleInput!
    weak var moduleOutput: PasscodeModuleOutput?

    func system(feedbacks: [Feedback]) {

    }
}
