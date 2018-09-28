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

protocol ChooseAccountPresenterProtocol {

    typealias Feedback = (Driver<ChooseAccountTypes.State>) -> Signal<ChooseAccountTypes.Event>

    var interactor: ChooseAccountInteractorProtocol! { get set }
    var input: ChooseAccountModuleInput! { get set }
    var moduleOutput: ChooseAccountModuleOutput? { get set }
    func system(feedbacks: [Feedback])
}

final class ChooseAccountPresenter: ChooseAccountPresenterProtocol {

    fileprivate typealias Types = ChooseAccountTypes

    var interactor: ChooseAccountInteractorProtocol!
    var input: ChooseAccountModuleInput!
    weak var moduleOutput: ChooseAccountModuleOutput?

    private var walletsInteractor: WalletsInteractorProtocol = FactoryInteractors.instance.wallets

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(walletsFeedback())
        let initialState = self.initialState()
        let system = Driver.system(initialState: initialState,
                                   reduce: ChooseAccountPresenter.reduce,
                                   feedback: newFeedbacks)
        system
            .drive()
            .disposed(by: disposeBag)
    }

    private func walletsFeedback() -> Feedback {
        return react(query: { state -> Bool? in
            return state.isAppeared == true ? true : nil
        }, effects: { [weak self] query -> Signal<Types.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .walletsInteractor
                .wallets()
                .map { Types.Event.setWallets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }
}

// MARK: Core State

private extension ChooseAccountPresenter {

    static func reduce(state: Types.State, event: Types.Event) -> Types.State {
        switch event {
        case .readyView:
            return state.mutate(transform: {
                $0.isAppeared = true
            })
        case .setWallets(let wallets):
            return state.mutate(transform: {
                $0.displayState.wallets = wallets
            })
        default:
            break
        }
        return state
    }
}

// MARK: UI State

private extension ChooseAccountPresenter {

    func initialState() -> Types.State {
        return Types.State(displayState: initialDisplayState(), action: nil, isAppeared: false)
    }

    func initialDisplayState() -> Types.DisplayState {
        return Types.DisplayState(wallets: [])
    }
}
