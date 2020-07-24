//
//  DexCreateOrderPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import RxFeedback
import RxSwift

final class DexCreateOrderPresenter: DexCreateOrderPresenterProtocol {
    private let interactor: DexCreateOrderInteractorProtocol
    private let pair: DomainLayer.DTO.Dex.Pair

    private let disposeBag = DisposeBag()

    init(interactor: DexCreateOrderInteractorProtocol, pair: DomainLayer.DTO.Dex.Pair) {
        self.interactor = interactor
        self.pair = pair
    }

    func system(feedbacks: [DexCreateOrderPresenter.Feedback], feeAssetId: String) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        newFeedbacks.append(feeQuery())
        newFeedbacks.append(isValidOrderQuery())
        newFeedbacks.append(calculateMarketPriceQuery())
        newFeedbacks.append(getDevelopmentConfig())

        Driver.system(initialState: DexCreateOrder.State.initialState(feeAssetId: feeAssetId),
                      reduce: { [weak self] state, event -> DexCreateOrder.State in
                          guard let self = self else { return state }
                        
                          return self.reduce(state: state, event: event)
                      },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }

    private func feeQuery() -> Feedback {
        react(request: { state -> DexCreateOrder.State? in state.isNeedGetFee ? state : nil },
              effects: { [weak self] state -> Signal<DexCreateOrder.Event> in
                
                guard let self = self else { return Signal.empty() }
                
                let amountAssetId = self.pair.amountAsset.id
                let priceAssetId = self.pair.priceAsset.id
                let selectedFeeAssetId = state.feeAssetId
                
                return self
                    .interactor
                    .getFee(amountAsset: amountAssetId, priceAsset: priceAssetId, selectedFeeAssetId: selectedFeeAssetId)
                    .map { .didGetFee($0) }
                    .asSignal(onErrorRecover: { Signal.just(.handlerFeeError($0)) })
        })
    }
    
    private func calculateMarketPriceQuery() -> Feedback {
        react(request: { state -> DexCreateOrder.State? in state.isNeedCalculateMarketOrderPrice ? state : nil },
              effects: { [weak self] state -> Signal<DexCreateOrder.Event> in
                
                guard let self = self else { return Signal.empty() }
                guard let order = state.order else { return Signal.empty() }
                
                return self.interactor.calculateMarketOrderPrice(amountAsset: order.amountAsset,
                                                                 priceAsset: order.priceAsset,
                                                                 orderAmount: order.amount,
                                                                 type: order.type)
                    .map { .didGetMarketOrderPrice($0) }
                    .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func modelsQuery() -> Feedback {
        react(request: { state -> DexCreateOrder.State? in state.isNeedCreateOrder ? state : nil },
              effects: { [weak self] state -> Signal<DexCreateOrder.Event> in
                
                guard let self = self else { return Signal.empty() }
                guard let order = state.order else { return Signal.empty() }
                
                return self.interactor.createOrder(order: order,
                                                   type: state.createOrderType)
                    .map { .orderDidCreate($0) }
                    .asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func isValidOrderQuery() -> Feedback {
        react(request: { state -> DexCreateOrder.State? in state.isNeedCheckValidOrder ? state : nil },
              effects: { [weak self] ss -> Signal<DexCreateOrder.Event> in
                guard let self = self else { return Signal.empty() }
                guard let order = ss.order else { return Signal.empty() }
                
                return self
                    .interactor
                    .isValidOrder(order: order)
                    .map { $0 == true ? .sendOrder : .orderNotValid(.invalid) }
                    .asSignal(onErrorRecover: { (error) -> Signal<DexCreateOrder.Event> in
                        if let error = error as? DexCreateOrder.CreateOrderError {
                            return Signal.just(.orderNotValid(error))
                        } else {
                            return Signal.just(.orderNotValid(.invalid))
                        }
                    })
        })
    }
    
    private func getDevelopmentConfig() -> Feedback {
        react(request: { state -> DexCreateOrder.State? in state.isNeedCheckPairs ? state : nil },
              effects: { [weak self] _ -> Signal<DexCreateOrder.Event> in
                guard let self = self else { return Signal.never() }
                
                return self.interactor.getDevConfig()
                    .map { [weak self] config -> DexCreateOrder.Event in
                        
                        let amountName = self?.pair.amountAsset.displayName ?? ""
                        let priceName = self?.pair.priceAsset.displayName ?? ""
                        
                        let checkPair = "\(amountName)/\(priceName)"
                        
                        let pairs = Set(config.marketPairs.map { "\($0.amount)/\($0.price)" })
                        
                        let isVisible = pairs.contains(checkPair)
                        
                        return .updateVisibleOrderTypesContainer(isVisible)
                }
                .asSignal(onErrorJustReturn: .updateVisibleOrderTypesContainer(true))
        })
    }

    private func reduce(state: DexCreateOrder.State, event: DexCreateOrder.Event) -> DexCreateOrder.State {
        switch event {
        case .refreshFee:
            return state.mutate {
                $0.isNeedGetFee = true
            }
            .changeAction(.none)

        case let .feeAssetNeedUpdate(feeAssetId):
            return state.mutate {
                $0.feeAssetId = feeAssetId
                $0.isNeedGetFee = true
            }.changeAction(.none)

        case let .handlerFeeError(error):
            return state.mutate {
                $0.isNeedGetFee = false
                $0.isDisabledSellBuyButton = true
                if let error = error as? TransactionsUseCaseError, error == .commissionReceiving {
                    let error = DisplayError.message(Localizable.Waves.Transaction.Error.Commission.receiving)
                    $0.displayFeeErrorState = .error(error)
                } else {
                    $0.displayFeeErrorState = .error(DisplayError(error: error))
                }
            }
            .changeAction(.none)

        case let .didGetFee(feeSettings):
            return state.mutate {
                $0.isNeedGetFee = false
                $0.isDisabledSellBuyButton = false
                $0.displayFeeErrorState = .none
                $0.order?.fee = feeSettings.fee.amount
            }
            .changeAction(.didGetFee(feeSettings))

        case .createOrder:
            if state.order?.type == .buy {
                UseCasesFactory.instance.analyticManager.trackEvent(.dex(.buyOrderSuccess(amountAsset: pair.amountAsset.name,
                                                                                          priceAsset: pair.priceAsset.name)))
            } else {
                UseCasesFactory.instance.analyticManager.trackEvent(.dex(.sellOrderSuccess(amountAsset: pair.amountAsset.name,
                                                                                           priceAsset: pair.priceAsset.name)))
            }

            return state.mutate {
                $0.isNeedCreateOrder = false
                $0.isNeedCheckValidOrder = true
            }
            .changeAction(.showCreatingOrderState)

        case .cancelCreateOrder:
            return state.mutate {
                $0.isNeedCreateOrder = false
                $0.isNeedCheckValidOrder = false
            }
            .changeAction(.showDeffaultOrderState)

        case .sendOrder:
            return state.mutate {
                $0.isNeedCreateOrder = true
                $0.isNeedCheckValidOrder = false
            }
            .changeAction(.showCreatingOrderState)

        case let .orderNotValid(error):
            return state.mutate {
                $0.isNeedCreateOrder = false
                $0.isNeedCheckValidOrder = false
            }
            .changeAction(.orderNotValid(error))

        case let .orderDidCreate(responce):
            return state.mutate {
                $0.isNeedCreateOrder = false

                switch responce.result {
                case let .error(error):
                    $0.action = .orderDidFailCreate(error)
                case let .success(output):
                    $0.action = .orderDidCreate(output)
                }
            }

        case let .updateInputOrder(order):
            return state.mutate {
                $0.isNeedCreateOrder = false

                if $0.createOrderType == .market &&
                    ($0.order?.amount.decimalValue != order.amount.decimalValue || $0.order?.type != order.type) {
                    $0.isNeedCalculateMarketOrderPrice = true
                }

                $0.order = order
            }.changeAction(.none)

        case let .changeCreateOrderType(type):
            return state.mutate {
                $0.createOrderType = type
                $0.isNeedCalculateMarketOrderPrice = type == .market
            }.changeAction(.updateCreateOrderType(type))

        case .updateMarketOrderPrice:
            return state.mutate {
                $0.isNeedCalculateMarketOrderPrice = true
            }.changeAction(.none)

        case let .didGetMarketOrderPrice(marketOrder):
            return state.mutate {
                $0.isNeedCalculateMarketOrderPrice = false
                $0.order?.price = marketOrder.price
                $0.order?.total = marketOrder.total
            }.changeAction(.updateMarketOrderPrice(marketOrder))

        case let .updateVisibleOrderTypesContainer(isVisible):
            return state.mutate { state in
                state.isNeedCheckPairs = false
                state.isVisibleOrderTypesContainer = isVisible
            }
        }
    }
}

fileprivate extension DexCreateOrder.State {
    func changeAction(_ action: DexCreateOrder.State.Action) -> DexCreateOrder.State {
        mutate { $0.action = action }
    }
}

fileprivate extension DexCreateOrder.State {
    static func initialState(feeAssetId: String) -> DexCreateOrder.State {
        DexCreateOrder.State(isNeedCheckPairs: true,
                             isVisibleOrderTypesContainer: true,
                             isNeedCreateOrder: false,
                             isNeedCheckValidOrder: false,
                             isNeedGetFee: true,
                             order: nil,
                             action: .none,
                             displayFeeErrorState: .none,
                             isDisabledSellBuyButton: false,
                             feeAssetId: feeAssetId,
                             createOrderType: .limit,
                             isNeedCalculateMarketOrderPrice: false)
    }
}
