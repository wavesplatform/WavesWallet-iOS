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

    var interactor: WalletInteractorProtocol!
    weak var moduleOutput: WalletModuleOutput?

    private let disposeBag: DisposeBag = DisposeBag()

    func system(feedbacks: [Feedback]) {

        var newFeedbacks = feedbacks
        newFeedbacks.append(queryAssets())
        newFeedbacks.append(queryLeasing())

        Driver
            .system(initialState: WalletPresenter.initialState(),
                    reduce: reduce,
                    feedback: newFeedbacks)

            .drive()
            .disposed(by: disposeBag)
    }

    private func queryAssets() -> Feedback {
        return react(query: { (state) -> Bool? in

            if state.isAppeared && state.display == .assets {
                return true
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

    private func queryLeasing() -> Feedback {
        return react(query: { (state) -> Bool? in

            if state.isAppeared && state.display == .leasing {
                return true
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
            return state.setIsAppeared(true)

        case .tapSortButton:
            moduleOutput?.showWalletSort()
            return state

        case .tapAddressButton:
            moduleOutput?.showMyAddress()
            return state

        case .refresh:
            switch state.display {
            case .assets:
                interactor.refreshAssets()
            case .leasing:
                interactor.refreshLeasing()
            }
            return state.setIsRefreshing(isRefreshing: true)

        case .tapRow(let indexPath):

            guard let asset = state.visibleSections[indexPath.section].items[indexPath.row].asset else { return state }
            moduleOutput?.showAsset(with: asset)

            return state
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
