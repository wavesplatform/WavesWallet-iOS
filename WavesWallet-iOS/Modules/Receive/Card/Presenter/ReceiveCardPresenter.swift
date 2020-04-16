//
//  ReceiveCardPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import RxFeedback
import RxSwift
import WavesSDK

final class ReceiveCardPresenter: ReceiveCardPresenterProtocol {
    var interactor: ReceiveCardInteractorProtocol!
    private let disposeBag = DisposeBag()

    private let coinomateRepository = UseCasesFactory.instance.repositories.coinomatRepository

    func system(feedbacks: [ReceiveCardPresenter.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        newFeedbacks.append(generateLinkQuery())
        newFeedbacks.append(wavesAmountQuery())

        Driver.system(initialState: ReceiveCard.State.initialState,
                      reduce: { state, event -> ReceiveCard.State in
                          ReceiveCardPresenter.reduce(state: state, event: event)
                      },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }

    private func wavesAmountQuery() -> Feedback {
        return react(request: { state -> ReceiveCard.State? in
            state.isNeedLoadPriceInfo ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveCard.Event> in

            guard let self = self else { return Signal.empty() }

            let emptyAmount: Signal<ReceiveCard.Event> = Signal.just(.didGetPriceInfo(
                ResponseType(output: Money(0, WavesSDKConstants.WavesDecimals), error: nil)))
                .asSignal(onErrorSignalWith: Signal.empty())

            guard let amount = state.amount else { return emptyAmount }

            if amount.amount > 0 {
                return self.interactor.getWavesAmount(fiatAmount: amount, fiatType: state.fiatType)
                    .map { .didGetPriceInfo($0) }.asSignal(onErrorSignalWith: Signal.empty())
            }
            return emptyAmount
        })
    }

    private func modelsQuery() -> Feedback {
        return react(request: { state -> ReceiveCard.State? in
            state.isNeedLoadInfo ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveCard.Event> in

            guard let self = self else { return Signal.empty() }
            return self.interactor.getInfo(fiatType: state.fiatType).map { .didGetInfo($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func generateLinkQuery() -> Feedback {
        return react(request: { state -> ReceiveCard.State? in
            state.isNeedLoadPriceInfo ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveCard.Event> in

            guard let self = self else { return Signal.empty() }
            guard let amount = state.amount else { return Signal.empty() }

            return self.coinomateRepository.generateBuyLink(address: state.address,
                                                            amount: amount.doubleValue,
                                                            fiat: state.fiatType.id)
                .map { .linkDidGenerate($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private static func reduce(state: ReceiveCard.State, event: ReceiveCard.Event) -> ReceiveCard.State {
        switch event {
        case let .linkDidGenerate(link):
            return state.mutate {
                $0.action = .changeUrl
                $0.link = link
            }

        case .updateAmountWithUSDFiat:
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedLoadPriceInfo = true
                $0.fiatType = .usd
                $0.action = .none
            }

        case .updateAmountWithEURFiat:
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedLoadPriceInfo = true
                $0.fiatType = .eur
                $0.action = .none
            }

        case let .updateAmount(money):

            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedLoadPriceInfo = true
                $0.amount = money
                $0.action = .none
            }

        case .getUSDAmountInfo:
            return state.mutate {
                $0.isNeedLoadInfo = true
                $0.isNeedLoadPriceInfo = true
                $0.fiatType = .usd
                $0.action = .none
            }

        case .getEURAmountInfo:
            return state.mutate {
                $0.isNeedLoadInfo = true
                $0.isNeedLoadPriceInfo = true
                $0.fiatType = .eur
                $0.action = .none
            }

        case let .didGetInfo(responce):
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedLoadPriceInfo = false

                switch responce.result {
                case let .success(info):

                    $0.assetBalance = info.asset
                    $0.address = info.address

                    switch info.amountInfo.type {
                    case .eur:
                        $0.amountEURInfo = info.amountInfo

                    case .usd:
                        $0.amountUSDInfo = info.amountInfo
                    }

                    $0.action = .didGetInfo

                case let .error(error):
                    $0.action = .didFailGetInfo(error)
                }
            }

        case let .didGetPriceInfo(priceInfo):

            return state.mutate {
                $0.isNeedLoadPriceInfo = false

                switch priceInfo.result {
                case let .success(money):
                    $0.action = .didGetWavesAmount(money)

                case let .error(error):
                    $0.action = .didFailGetWavesAmount(error)
                }
            }
        }
    }
}

fileprivate extension ReceiveCard.State {
    static var initialState: ReceiveCard.State {
        return ReceiveCard.State(isNeedLoadInfo: true,
                                 isNeedLoadPriceInfo: false,
                                 fiatType: .usd,
                                 action: .none,
                                 link: "",
                                 amountUSDInfo: nil,
                                 amountEURInfo: nil,
                                 assetBalance: nil,
                                 amount: nil,
                                 address: "")
    }
}
