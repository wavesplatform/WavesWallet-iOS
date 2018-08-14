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

final class AsssetPresenter: AsssetPresenterProtocol {

    typealias Feedback = (Driver<AssetTypes.DisplayState>) -> Signal<AssetTypes.DisplayEvent>

    typealias FeedbackCore = (Driver<AssetTypes.State>) -> Signal<AssetTypes.Event>

    var interactor: AssetsInteractorProtocol!
    private var disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks

        Driver.system(initialState: AssetTypes.State(),
                      reduce: { [unowned self] state, event in self.reduceCore(state: state, event: event) },
                      feedback: react(query: { (_) -> Bool? in
                          true
                      }, effects: { [unowned self] (_) -> Signal<AssetTypes.Event> in

                          let ui = Driver.system(initialState: AssetTypes.DisplayState(),
                                                 reduce: { [unowned self] state, event in self.reduceUI(state: state, event: event) },
                                                 feedback: feedbacks)
                          return ui
                              .map({ (state) -> AssetTypes.Event in self.reduceEvent(state: state) })
                              .debug("KoRa UI")
                              .asSignal(onErrorSignalWith: Signal<AssetTypes.Event>.empty())
        }))
            .debug(" Gopka ")
            .drive()
            .disposed(by: disposeBag)
    }

    deinit {
        debug("Ala din")
    }
}

extension AsssetPresenter {

    func reduceEvent(state: AssetTypes.DisplayState) -> AssetTypes.Event {

        return AssetTypes.Event.updated(.init())
    }

    func reduceCore(state: AssetTypes.State, event: AssetTypes.Event) -> AssetTypes.State {

        return AssetTypes.State()
    }

    func reduceUI(state: AssetTypes.DisplayState, event: AssetTypes.DisplayEvent) -> AssetTypes.DisplayState {

        return AssetTypes.DisplayState()
    }
}
