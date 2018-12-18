//
//  ReceiveCardPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

final class ReceiveCardPresenter: ReceiveCardPresenterProtocol {
    
    var interactor: ReceiveCardInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    
    func system(feedbacks: [ReceiveCardPresenter.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        newFeedbacks.append(wavesAmountQuery())
        
        Driver.system(initialState: ReceiveCard.State.initialState,
                      reduce: { state, event -> ReceiveCard.State in
                        return ReceiveCardPresenter.reduce(state: state, event: event) },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func wavesAmountQuery() -> Feedback {
        return react(query: { state -> ReceiveCard.State? in
            return state.isNeedLoadPriceInfo ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveCard.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }
            
            let emptyAmount: Signal<ReceiveCard.Event> = Signal.just(.didGetPriceInfo(ResponseType(output: Money(0, GlobalConstants.WavesDecimals), error: nil))).asSignal(onErrorSignalWith: Signal.empty())
            
            guard let amount = state.amount else { return emptyAmount }

            if amount.amount > 0 {
                return strongSelf.interactor.getWavesAmount(fiatAmount: amount, fiatType: state.fiatType)
                    .map {.didGetPriceInfo($0)}.asSignal(onErrorSignalWith: Signal.empty())
            }
            return emptyAmount
        })
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> ReceiveCard.State? in
            return state.isNeedLoadInfo ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveCard.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.getInfo(fiatType: state.fiatType).map {.didGetInfo($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    static private func reduce(state: ReceiveCard.State, event: ReceiveCard.Event) -> ReceiveCard.State {
        
        switch event {

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
            
        case .updateAmount(let money):
            
            return state.mutate {
                $0.action = .changeUrl
                $0.isNeedLoadInfo = false
                $0.isNeedLoadPriceInfo = true
                $0.amount = money
                
                if let asset = state.assetBalance?.asset {
                    
                    let params = ["crypto" : asset.wavesId ?? "",
                                 "address" : state.address,
                                 "amount" : String(money.doubleValue),
                                 "fiat" : state.fiatType.id]
                    
                    $0.link = Receive.DTO.urlFromPath(GlobalConstants.Coinomat.buy, params: params)
                }
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
        
        case .didGetInfo(let responce):
            return state.mutate {
                $0.isNeedLoadInfo = false
                $0.isNeedLoadPriceInfo = false

                switch responce.result {
                case .success(let info):
                    
                    $0.assetBalance = info.asset
                    $0.address = info.address
                    
                    switch info.amountInfo.type {
                    case .eur:
                        $0.amountEURInfo = info.amountInfo
                        
                    case .usd:
                        $0.amountUSDInfo = info.amountInfo
                    }
                    
                    $0.action = .didGetInfo

                case .error(let error):
                    $0.action = .didFailGetInfo(error)
                }
            }
            
        case .didGetPriceInfo(let priceInfo):
            
            return state.mutate {
                $0.isNeedLoadPriceInfo = false
                
                switch priceInfo.result {
                case .success(let money):
                    $0.action = .didGetWavesAmount(money)
                
                case .error(let error):
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
