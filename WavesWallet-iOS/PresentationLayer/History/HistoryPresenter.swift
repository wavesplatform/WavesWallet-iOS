//
//  HistoryPresenter.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

protocol HistoryPresenterProtocol {
    typealias Feedback = (Driver<HistoryTypes.State>) -> Signal<HistoryTypes.Event>
    
    func system(feedbacks: [Feedback])
}

final class HistoryPresenter: HistoryPresenterProtocol {
    private let interactor: HistoryInteractorProtocol = HistoryInteractorMock()
    private let disposeBag: DisposeBag = DisposeBag()
    
    func system(feedbacks: [Feedback]) {
        var newFeedbacks = feedbacks
//        newFeedbacks.append(queryAll())
//        newFeedbacks.append(queryAll())
        
        Driver.system(initialState: HistoryPresenter.initialState(), reduce: reduce, feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
//    private func queryAll() -> Feedback {
//        return react(query: { (state) -> Bool? in
//
//            return nil
//
//        }, effects: { [weak self] _ -> Signal<HistoryTypes.Event> in
//            guard let strongSelf = self else { return Signal.empty() }
//            return strongSelf
//                .interactor
//                .all()
//                .map { .responseAll($0) }
//                .asSignal(onErrorSignalWith: Signal.empty())
//        })
//    }
    
    private func reduce(state: HistoryTypes.State, event: HistoryTypes.Event) -> HistoryTypes.State {
        return state
    }
    
    private static func initialState() -> HistoryTypes.State {
        return HistoryTypes.State.initialState()
    }
    
}
