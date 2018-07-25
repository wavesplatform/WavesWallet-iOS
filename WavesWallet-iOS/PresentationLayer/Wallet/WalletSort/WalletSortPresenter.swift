//
//  WalletSortPresenter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

protocol WalletSortPresenterProtocol {
    typealias Feedback = (Driver<WalletSort.State>) -> Signal<WalletSort.Event>

    func system(bindings: @escaping Feedback)
}


final class WalletSortPresenter: WalletSortPresenterProtocol {

    private let disposeBag = DisposeBag()

    func system(bindings: @escaping Feedback) {

        Driver.system(initialState: WalletSort.State.initialState,
                      reduce: reduce,
                      feedback: bindings)
            .drive()
            .disposed(by: disposeBag)
    }

    private func reduce(state: WalletSort.State, event: WalletSort.Event) -> WalletSort.State {
        switch event {
        case .dragAsset(let indexPath):
            break
        case .readyView:
            break
        case .tapFavoriteButton(let indexPath):
            break
        }
        return state
    }
}

fileprivate extension WalletSort.State {

    static var initialState: WalletSort.State {
        return WalletSort.State(sections: [])
    }
}
