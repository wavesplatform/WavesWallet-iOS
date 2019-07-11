//
//  DexCreateOrderPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa
import Extensions
import DomainLayer

final class DexCreateOrderPresenter: DexCreateOrderPresenterProtocol {

    
    var interactor: DexCreateOrderInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    var pair: DomainLayer.DTO.Dex.Pair!
    
    func system(feedbacks: [DexCreateOrderPresenter.Feedback], feeAssetId: String) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        newFeedbacks.append(feeQuery())
        newFeedbacks.append(isValidOrderQuery())

        Driver.system(initialState: DexCreateOrder.State.initialState(feeAssetId: feeAssetId),
                      reduce: { [weak self] state, event -> DexCreateOrder.State in

                        guard let self = self else { return state }
                        return self.reduce(state: state, event: event)
                    }, feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func feeQuery() -> Feedback {
        return react(request: { state -> DexCreateOrder.State? in
            return state.isNeedGetFee ? state : nil
        }, effects: { [weak self] state -> Signal<DexCreateOrder.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self
                .interactor
                .getFee(amountAsset: self.pair.amountAsset.id, priceAsset: self.pair.priceAsset.id, feeAssetId: state.feeAssetId)
                .map {.didGetFee($0)}
                .asSignal(onErrorRecover: { Signal.just(.handlerFeeError($0)) } )
        })
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(request: { state -> DexCreateOrder.State? in
            return state.isNeedCreateOrder ? state : nil
        }, effects: { [weak self] ss -> Signal<DexCreateOrder.Event> in
            
            guard let self = self else { return Signal.empty() }
            guard let order = ss.order else { return Signal.empty() }

            return self.interactor.createOrder(order: order).map { .orderDidCreate($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func isValidOrderQuery() -> Feedback {
        
        return react(request: { state -> DexCreateOrder.State? in
            return state.isNeedCheckValidOrder ? state : nil
        }, effects: { [weak self] ss -> Signal<DexCreateOrder.Event> in
            
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
    
    private func reduce(state: DexCreateOrder.State, event: DexCreateOrder.Event) -> DexCreateOrder.State {
        
        switch event {
        case .refreshFee:

            return state.mutate {
                $0.isNeedGetFee = true
            }
            .changeAction(.none)

        case .feeAssetNeedUpdate(let feeAssetId):
            
            return state.mutate {
                $0.feeAssetId = feeAssetId
                $0.isNeedGetFee = true
            }.changeAction(.none)
            
        case .handlerFeeError(let error):

            return state.mutate {
                $0.isNeedGetFee = false
                $0.isDisabledSellBuyButton = true
                if let error = error as? TransactionsUseCaseError, error == .commissionReceiving {
                    $0.displayFeeErrorState = .error(DisplayError.message(Localizable.Waves.Transaction.Error.Commission.receiving))
                } else {
                    $0.displayFeeErrorState = .error(DisplayError(error: error))
                }
            }
            .changeAction(.none)

        case .didGetFee(let feeSettings):
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
            }
            else {
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
            
        case .orderNotValid(let error):
            
            return state.mutate {
                $0.isNeedCreateOrder = false
                $0.isNeedCheckValidOrder = false
            }
            .changeAction(.orderNotValid(error))
            
        case .orderDidCreate(let responce):
            
            return state.mutate {
                
                $0.isNeedCreateOrder = false
                
                switch responce.result {
                    case .error(let error):
                        $0.action = .orderDidFailCreate(error)
                    
                    case .success(let output):
                        $0.action = .orderDidCreate(output)
                }
            }

            
        case .updateInputOrder(let order):
            return state.mutate {
                $0.isNeedCreateOrder = false
                $0.order = order
            }.changeAction(.none)
        }
    }
    
}

fileprivate extension DexCreateOrder.State {
    
    func changeAction(_ action: DexCreateOrder.State.Action) -> DexCreateOrder.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
    
fileprivate extension DexCreateOrder.State {
    static func initialState(feeAssetId: String) -> DexCreateOrder.State {
        return DexCreateOrder.State(isNeedCreateOrder: false,
                                    isNeedCheckValidOrder: false,
                                    isNeedGetFee: true,
                                    order: nil,
                                    action: .none,
                                    displayFeeErrorState: .none,
                                    isDisabledSellBuyButton: false,
                                    feeAssetId: feeAssetId)
    }
}
