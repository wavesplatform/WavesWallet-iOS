//
//  WalletsViewModel.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import RxSwift

private enum ReactQuery {
    case new
    case refresh
}

final class WalletPresenter: WalletPresenterProtocol {
    private let interactor: WalletInteractorProtocol = WalletInteractor()
    private let disposeBag: DisposeBag = DisposeBag()

    var moduleOutput: WalletModuleOutput?

    func system(bindings: @escaping Feedback) {
        Driver
            .system(initialState: WalletPresenter.initialState(),
                    reduce: reduce,
                    feedback: bindings,
                    queryAssets(),
                    queryLeasing())

            .drive()
            .disposed(by: disposeBag)
    }

    private func queryAssets() -> (Driver<WalletTypes.State>) -> Signal<WalletTypes.Event> {
        return react(query: { (state) -> ReactQuery? in

            if state.display == .assets {
                return state.assets.isRefreshing ? .new : .refresh
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .interactor
                .assets()
                .map { .responseAssets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func queryLeasing() -> (Driver<WalletTypes.State>) -> Signal<WalletTypes.Event> {
        return react(query: { (state) -> ReactQuery? in

            if state.display == .leasing {
                return state.leasing.isRefreshing ? .new : .refresh
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .interactor
                .leasing()
                .map { .responseLeasing($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func reduce(state: WalletTypes.State, event: WalletTypes.Event) -> WalletTypes.State {
        switch event {
        case .readyView:

            return state
        case .tapSortButton:
            moduleOutput?.showWalletSort()

            return state
        case .tapAddressButton:
            moduleOutput?.showMyAddress()
            return state

        case .refresh:
            return state.setIsRefreshing(isRefreshing: true)

        case .tapSection(let section):
            return state.toggleCollapse(index: section)

        case .changeDisplay(let display):
            return state.setDisplay(display: display)

        case .responseAssets(let response):

            let secions = WalletTypes.ViewModel.Section.map(from: response)
            let newState = state.setAssets(assets: .init(sections: secions,
                                                         collapsedSections: state.assets.collapsedSections,
                                                         isRefreshing: false,
                                                         animateType: .refresh))

            return newState
            
        case .responseLeasing(let response):
            let secions = WalletTypes.ViewModel.Section.map(from: response)
            let newState = state.setLeasing(leasing: .init(sections: secions,
                                                           collapsedSections: state.leasing.collapsedSections,
                                                           isRefreshing: false,
                                                           animateType: .refresh))

            return newState
        }
    }

    private static func initialState() -> WalletTypes.State {
        return WalletTypes.State.initialState()
    }
}
