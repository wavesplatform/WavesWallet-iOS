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

    private typealias FeedbackCore = (Driver<AssetTypes.State>) -> Signal<AssetTypes.Event>

    var interactor: AssetsInteractorProtocol!
    private var disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {


        Driver.system(initialState: AssetTypes.State(),
                      reduce: { [unowned self] state, event in self.reduceCore(state: state, event: event) },
                      feedback: reactUI(feedbacks: feedbacks))
            .debug(" Gopka ")
            .drive()
            .disposed(by: disposeBag)
    }

    private func reactUI(feedbacks: [AsssetPresenterProtocol.Feedback]) -> FeedbackCore {
        return react(query: { _ in return true },
                     effects: { [unowned self] _ -> Signal<AssetTypes.Event> in

                        return Driver.system(initialState: AssetTypes.DisplayState(),
                                               reduce: { [unowned self] state, event in self.reduceUI(state: state, event: event) },
                                               feedback: feedbacks)
                            .map({ [unowned self] state -> AssetTypes.Event in self.reduceEvent(state: state) })
                            .debug("Removed")
                            .asSignal(onErrorSignalWith: Signal<AssetTypes.Event>.empty())
        })
    }

   private  func systemUI(feedbacks:  [AsssetPresenterProtocol.Feedback]) -> Driver<AssetTypes.DisplayState> {
        return Driver.system(initialState: AssetTypes.DisplayState(sections: []),
                             reduce: { [unowned self] state, event in self.reduceUI(state: state, event: event) },
                             feedback: feedbacks)
    }

    deinit {
        debug("Ala din")
    }
}

extension AsssetPresenter {

    func reduceEvent(state: AssetTypes.DisplayState) -> AssetTypes.Event {

        return AssetTypes.Event.none
    }

    func reduceCore(state: AssetTypes.State, event: AssetTypes.Event) -> AssetTypes.State {

        return AssetTypes.State(assets: [], displayState: .init(sections: []))
    }

    func reduceUI(state: AssetTypes.DisplayState, event: AssetTypes.DisplayEvent) -> AssetTypes.DisplayState {

        return AssetTypes.DisplayState(sections: [])
    }
}
