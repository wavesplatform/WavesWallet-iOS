//
//  StartLeasingPresenterP.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

final class StartLeasingPresenter: StartLeasingPresenterProtocol {
    
    var interactor: StartLeasingInteractorProtocol!
    private let disposeBag = DisposeBag()
    
    weak var moduleOutput: StartLeasingModuleOutput?
    
    func system(feedbacks: [StartLeasingPresenter.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: StartLeasing.State.initialState,
                      reduce: { [weak self] state, event -> StartLeasing.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> StartLeasing.State? in
            return state.isNeedCreateOrder ? state : nil
        }, effects: { [weak self] ss -> Signal<StartLeasing.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            guard let order = ss.order else { return Signal.empty() }
            
            return strongSelf
                .interactor
                .createOrder(order: order)
                .map { _ in .orderDidCreate }
                .asSignal(onErrorSignalWith: Signal.just(.handlerError))
        })
    }
    
    private func reduce(state: StartLeasing.State, event: StartLeasing.Event) -> StartLeasing.State {
        
        switch event {
        case .createOrder:
            
            return state.mutate {
                $0.isNeedCreateOrder = true
            }.changeAction(.showCreatingOrderState)

        case .handlerError:
            return state.mutate {
                $0.action = .orderDidFailCreate("error")
            }
        case .orderDidCreate:
            
            return state.mutate {
                
                $0.isNeedCreateOrder = false
                moduleOutput?.startLeasingDidCreateOrder()
                $0.action = .orderDidCreate
  
//                switch responce.result {
//                case .error(let error):
//                    $0.action = .orderDidFailCreate(error)
//
//                case .success(let success):
//                    if success {
//                        moduleOutput?.startLeasingDidCreateOrder()
//                        $0.action = .orderDidCreate
//                    }
//                    else {
//                        $0.action = .none
//                    }
//                }
            }
            
        case .updateInputOrder(let order):
            return state.mutate {
                $0.isNeedCreateOrder = false
                $0.order = order
            }.changeAction(.none)
        }
    }
    
}


fileprivate extension StartLeasing.State {
    
    static var initialState: StartLeasing.State {
        return StartLeasing.State(isNeedCreateOrder: false, order: nil, action: .none)
    }
    
    func changeAction(_ action: StartLeasing.State.Action) -> StartLeasing.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
