//
//  DexOrderBookPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RxCocoa
import RxFeedback
import RxSwift

final class DexOrderBookPresenter: DexOrderBookPresenterProtocol {
    weak var moduleOutput: DexOrderBookModuleOutput?

    private let interactor: DexOrderBookInteractorProtocol!

    private let priceAsset: DomainLayer.DTO.Dex.Asset
    private let amountAsset: DomainLayer.DTO.Dex.Asset

    private let disposeBag = DisposeBag()

    init(interactor: DexOrderBookInteractorProtocol,
         priceAsset: DomainLayer.DTO.Dex.Asset,
         amountAsset: DomainLayer.DTO.Dex.Asset) {
        self.interactor = interactor
        self.priceAsset = priceAsset
        self.amountAsset = amountAsset
    }

    func system(feedbacks: [DexOrderBookPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())

        Driver.system(initialState: DexOrderBook.State.initialState,
                      reduce: { [weak self] state, event -> DexOrderBook.State in
                          guard let self = self else { return state }

                          return self.reduce(state: state, event: event)
                      },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }

    private func modelsQuery() -> Feedback {
        react(request: { state -> Bool? in state.isNeedRefreshing ? true : nil },
              effects: { [weak self] _ -> Signal<DexOrderBook.Event> in
                  guard let self = self else { return Signal.empty() }

                  return self.interactor.displayInfo().map { .setDisplayData($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func reduce(state: DexOrderBook.State, event: DexOrderBook.Event) -> DexOrderBook.State {
        switch event {
        case .readyView:
            return state.mutate {
                $0.isNeedRefreshing = true
            }.changeAction(.none)

        case .updateData:
            return state.mutate {
                $0.isNeedRefreshing = true
            }.changeAction(.none)

        case let .setDisplayData(data):

            if data.authWalletError {
                return state.mutate {
                    $0.isNeedRefreshing = false
                    $0.action = .none
                }
            }

            return state.mutate {
                let displayData = data.data
                let wasEmpty = $0.sections.count == 0 ? true : $0.sections.map { $0.items.count }.reduce(0, +) == 1

                $0.isNeedRefreshing = false
                $0.availableAmountAssetBalance = displayData.availableAmountAssetBalance
                $0.availablePriceAssetBalance = displayData.availablePriceAssetBalance
                $0.availableBalances = displayData.availableBalances
                $0.scriptedAssets = displayData.scriptedAssets

                let sectionAsks = DexOrderBook.ViewModel.Section(items: displayData.asks.map {
                    DexOrderBook.ViewModel.Row.ask($0)
                })

                let sectionLastPrice = DexOrderBook.ViewModel.Section(items:
                    [DexOrderBook.ViewModel.Row.lastPrice(displayData.lastPrice)])

                let sectionBids = DexOrderBook.ViewModel.Section(items: displayData.bids.map {
                    DexOrderBook.ViewModel.Row.bid($0)
                })

                $0.sections = [sectionAsks, sectionLastPrice, sectionBids]

                $0.header = displayData.header

                if !state.hasFirstTimeLoad {
                    $0.hasFirstTimeLoad = true
                }

                $0.action = wasEmpty ? .scrollTableToCenter : .update
            }

        case let .didTapBid(bid, inputMaxSum):

            if !inputMaxSum {
                UseCasesFactory.instance.analyticManager
                    .trackEvent(.dex(.sellTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))
            }

            moduleOutput?.didCreateOrder(bid, amountAsset: amountAsset, priceAsset: priceAsset,
                                         ask: state.lastAsk?.price,
                                         bid: state.lastBid?.price,
                                         last: state.lastPrice?.price,
                                         availableAmountAssetBalance: state.availableAmountAssetBalance,
                                         availablePriceAssetBalance: state.availablePriceAssetBalance,
                                         availableBalances: state.availableBalances,
                                         inputMaxSum: inputMaxSum,
                                         scriptedAssets: state.scriptedAssets)

            return state.changeAction(.none)

        case .didTapEmptyBid:
            UseCasesFactory.instance.analyticManager
                .trackEvent(.dex(.sellTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))

            moduleOutput?.didCreateEmptyOrder(amountAsset: amountAsset, priceAsset: priceAsset,
                                              orderType: .sell,
                                              ask: state.lastAsk?.price,
                                              bid: state.lastBid?.price,
                                              last: state.lastPrice?.price,
                                              availableAmountAssetBalance: state.availableAmountAssetBalance,
                                              availablePriceAssetBalance: state.availablePriceAssetBalance,
                                              availableBalances: state.availableBalances,
                                              scriptedAssets: state.scriptedAssets)

            return state.changeAction(.none)

        case let .didTapAsk(ask, inputMaxSum):

            if !inputMaxSum {
                UseCasesFactory.instance.analyticManager
                    .trackEvent(.dex(.buyTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))
            }

            moduleOutput?.didCreateOrder(ask, amountAsset: amountAsset, priceAsset: priceAsset,
                                         ask: state.lastAsk?.price,
                                         bid: state.lastBid?.price,
                                         last: state.lastPrice?.price,
                                         availableAmountAssetBalance: state.availableAmountAssetBalance,
                                         availablePriceAssetBalance: state.availablePriceAssetBalance,
                                         availableBalances: state.availableBalances,
                                         inputMaxSum: inputMaxSum,
                                         scriptedAssets: state.scriptedAssets)

            return state.changeAction(.none)

        case .didTamEmptyAsk:
            UseCasesFactory.instance.analyticManager
                .trackEvent(.dex(.buyTap(amountAsset: amountAsset.name, priceAsset: priceAsset.name)))

            moduleOutput?.didCreateEmptyOrder(amountAsset: amountAsset, priceAsset: priceAsset,
                                              orderType: .buy,
                                              ask: state.lastAsk?.price,
                                              bid: state.lastBid?.price,
                                              last: state.lastPrice?.price,
                                              availableAmountAssetBalance: state.availableAmountAssetBalance,
                                              availablePriceAssetBalance: state.availablePriceAssetBalance,
                                              availableBalances: state.availableBalances,
                                              scriptedAssets: state.scriptedAssets)

            return state.changeAction(.none)
        }
    }
}

fileprivate extension DexOrderBook.State {
    func changeAction(_ action: DexOrderBook.State.Action) -> DexOrderBook.State {
        mutate { $0.action = action }
    }
}
