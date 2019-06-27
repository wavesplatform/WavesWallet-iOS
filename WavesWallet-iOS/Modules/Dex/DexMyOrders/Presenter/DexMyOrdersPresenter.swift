//
//  DexMyOrdersPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa
import SwiftDate


final class DexMyOrdersPresenter: DexMyOrdersPresenterProtocol {
    
    var interactor: DexMyOrdersInteractorProtocol!
    private let disposeBag = DisposeBag()

    func system(feedbacks: [DexMyOrdersPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexMyOrders.State.initialState,
                      reduce: { [weak self] state, event -> DexMyOrders.State in
                        guard let self = self else { return state }
                        return self.reduce(state: state, event: event) }
            , feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(request: { state -> DexMyOrders.State? in
            return state.isNeedLoadOrders ? state : nil
        }, effects: { [weak self] state -> Signal<DexMyOrders.Event> in
            
            guard let self = self else { return Signal.empty() }
            
            return self.interactor.myOrders().map {.setOrders($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexMyOrders.State, event: DexMyOrders.Event) -> DexMyOrders.State {
        
        switch event {
        case .readyView:
            return state.mutate {
                $0.isNeedLoadOrders = true
            }.changeAction(.none)
        
        case .refresh:
            return state.mutate {
                $0.isNeedLoadOrders = true
            }.changeAction(.none)
            
        case .setOrders(let orders):
          
            return state.mutate {
                
                $0.isNeedLoadOrders = false

                $0.section.items.removeAll()
                for order in orders {
                    $0.section.items.append(DexMyOrders.ViewModel.Row.order(order))
                }                
            }.changeAction(.update)
    
        }
    }
}

fileprivate extension DexMyOrders.State {
    
    func changeAction(_ action: DexMyOrders.State.Action) -> DexMyOrders.State {
        
        return mutate { state in
            state.action = action
        }
    }
}

fileprivate extension DexMyOrders.State {
    static var initialState: DexMyOrders.State {
        let section = DexMyOrders.ViewModel.Section(items: [])
        return DexMyOrders.State(action: .none, section: section, isNeedLoadOrders: false)
    }
}
