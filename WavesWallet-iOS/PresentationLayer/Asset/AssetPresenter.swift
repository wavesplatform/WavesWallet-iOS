//
//  AssetViewPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

func readState<State, Event, Owner: AnyObject>(_ owner: Owner, reading: @escaping (Owner, State) -> Void) -> (Driver<State>) -> Signal<Event> {

    return bind(owner) { (owner, state) -> (Bindings<Event>) in

        let read = state.drive { [weak owner] state in
            guard let owner = owner else { return }
            reading(owner, state)
        }

        return Bindings(subscriptions: [read], events: [Signal<Event>]())
    }
}

final class AsssetPresenter: AsssetPresenterProtocol {

    private typealias FeedbackCore = (Driver<AssetTypes.State>) -> Signal<AssetTypes.Event>

    var interactor: AssetsInteractorProtocol!
    private var disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks

        let system = Driver.system(initialState: AsssetPresenter.initialState,
                                   reduce: AsssetPresenter.reduce,
                                   feedback: newFeedbacks)

        system
            .drive(onNext: { [weak self] state in
                self?.handlerEventOutput(state: state)
            })
            .disposed(by: disposeBag)
    }

    func handlerEventOutput(state: AssetTypes.State) {
        guard let event = state.event else { return }

        switch event {
        default:
            break
        }
    }
}

// MARK: Core State

private extension AsssetPresenter {

    class func reduce(state: AssetTypes.State, event: AssetTypes.Event) -> AssetTypes.State {
        
        return state
    }
}

// MARK: UI State

private extension AsssetPresenter {

    static var initialState: AssetTypes.State {
        return AssetTypes.State(event: nil, assets: [], displayState: initialDisplayState)
    }

    static var initialDisplayState: AssetTypes.DisplayState {
        return AssetTypes.DisplayState(sections: [], isAppeared: false, isRefreshing: false, isFavorite: false)
    }
}
