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

final class DexCreateOrderPresenter: DexCreateOrderPresenterProtocol {

    
    var interactor: DexCreateOrderInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    weak var moduleOutput: DexCreateOrderModuleOutput?
    
    func system(feedbacks: [DexCreateOrderPresenter.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexCreateOrder.State.initialState,
                      reduce: { [weak self] state, event -> DexCreateOrder.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func modelsQuery() -> Feedback {
    
      
        return react(query: { state -> DexCreateOrder.State? in
            return state.isNeedCreateOrder ? state : nil
        }, effects: { [weak self] ss -> Signal<DexCreateOrder.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            guard let order = ss.order else { return Signal.empty() }

            return strongSelf.interactor.createOrder(order: order).map { .orderDidCreate($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexCreateOrder.State, event: DexCreateOrder.Event) -> DexCreateOrder.State {
        
        switch event {
        case .createOrder:
            
            return state.mutate {
                $0.isNeedCreateOrder = true
            }.changeAction(.showCreatingOrderState)
            
        case .orderDidCreate(let responce):
            
            return state.mutate {
                
                $0.isNeedCreateOrder = false
                
                switch responce.result {
                    case .error(let error):
                        $0.action = .orderDidFailCreate(error)
                    
                    case .success(let output):
                        moduleOutput?.dexCreateOrderDidCreate(output: output)
                        $0.action = .orderDidCreate
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
    static var initialState: DexCreateOrder.State {
        return DexCreateOrder.State(isNeedCreateOrder: false, order: nil, action: .none)
    }
}
