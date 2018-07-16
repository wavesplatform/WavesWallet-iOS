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
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = AccountBalanceInteractor()
    private let disposeBag: DisposeBag = DisposeBag()

    func bindUI(feedback: @escaping Feedback) {
        Driver
            .system(initialState: WalletPresenter.initialState(),
                    reduce: WalletPresenter.reduce,
                    feedback: feedback,
                    query())

            .drive()
            .disposed(by: disposeBag)
    }

    private func query() -> (Driver<WalletTypes.State>) -> Signal<WalletTypes.Event> {
        return react(query: { (state) -> ReactQuery? in

            if state.assets.isRefreshing == true {
                return .refresh
            } else if state.display == .assets {
                return .new
            } else {
                return nil
            }

        }, effects: { [weak self] _ -> Signal<WalletTypes.Event> in

            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.accountBalanceInteractor
                .balanceBy(accountId: "3PCAB4sHXgvtu5NPoen6EXR5yaNbvsEA8Fj")
                .map { .responseAssets($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private static func reduce(state: WalletTypes.State, event: WalletTypes.Event) -> WalletTypes.State {
        switch event {
        case .none:
            return state
        case .readyView:
            return state
        case .refresh:
            return state.setIsRefreshing(isRefreshing: true)
        case .tapSection(let section):
            return state.toggleCollapse(index: section)
        case .changeDisplay(let display):
            return state.setDisplay(display: display)
        case .responseAssets(let response):

            var rows = [WalletTypes.ViewModel.Row]()
            var rowsSpam = [WalletTypes.ViewModel.Row]()

            response.forEach { balance in
                if balance.asset!.isSpam {
                    rowsSpam.append(.asset(.init(id: balance.assetId,
                                                 name: balance.asset!.name)))
                } else {
                    rows.append(.asset(.init(id: balance.assetId,
                                             name: balance.asset!.name)))
                }
            }

            let sectionSpam = WalletTypes.ViewModel.Section(header: "Spam",
                                                            items: rowsSpam,
                                                            isExpanded: true)

            let section = WalletTypes.ViewModel.Section(header: "Testing",
                                                        items: rows,
                                                        isExpanded: true)

            let newState = state.setAssets(assets: .init(sections: [section, sectionSpam],
                                                         collapsedSections: state.assets.collapsedSections,
                                                         isRefreshing: false,
                                                         animateType: .refresh))

            return newState
        }
    }

    private static func initialState() -> WalletTypes.State {
        return WalletTypes.State.initialState()
    }
}
