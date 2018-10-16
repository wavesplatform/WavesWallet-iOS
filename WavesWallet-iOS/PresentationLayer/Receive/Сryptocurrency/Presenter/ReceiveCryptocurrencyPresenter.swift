//
//  ReceiveCryptocurrencyPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa


final class ReceiveCryptocurrencyPresenter: ReceiveCryptocurrencyPresenterProtocol {
    
    var interactor: ReceiveCryptocurrencyInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    
    func system(feedbacks: [ReceiveCryptocurrencyPresenter.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: ReceiveCryptocurrency.State.initialState,
                      reduce: { [weak self] state, event -> ReceiveCryptocurrency.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> ReceiveCryptocurrency.State? in
            return state.isNeedGenerateAddress ? state : nil
        }, effects: { [weak self] state -> Signal<ReceiveCryptocurrency.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }
            guard let asset = state.asset else { return Signal.empty() }
            
            return strongSelf.interactor.generateAddress(asset: asset)
                .map { .addressDidGenerate($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: ReceiveCryptocurrency.State, event: ReceiveCryptocurrency.Event) -> ReceiveCryptocurrency.State {
        
        switch event {
       
        case .generateAddress(let asset):
            return state.mutate {
                $0.displayInfo = nil
                $0.asset = asset
                $0.isNeedGenerateAddress = true
            }.changeAction(.none)
            
        case .addressDidGenerate(let response):
            
            return state.mutate {
                $0.isNeedGenerateAddress = false
                $0.displayInfo = response.output
                
                switch response.result {
                    case .success(let info):
                        $0.action = .addressDidGenerate(info)
                    
                    case .error(let error):
                        $0.action = .addressDidFailGenerate(error)
                }
            }
        }
    }
    
}

fileprivate extension ReceiveCryptocurrency.State {
    
    static var initialState: ReceiveCryptocurrency.State {
    
        return ReceiveCryptocurrency.State(isNeedGenerateAddress: false, action: .none, displayInfo: nil, asset: nil)
    }
    
    func changeAction(_ action: ReceiveCryptocurrency.State.Action) -> ReceiveCryptocurrency.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
