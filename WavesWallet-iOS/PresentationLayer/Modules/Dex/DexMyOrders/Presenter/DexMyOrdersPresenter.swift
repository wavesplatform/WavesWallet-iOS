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
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    private func modelsQuery() -> Feedback {
        
        return react(query: { state -> DexMyOrders.State? in
            return state.isNeedLoadOrders || state.isNeedCancelOrder ? state : nil
        }, effects: { [weak self] state -> Signal<DexMyOrders.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }

            if let order = state.canceledOrder, state.isNeedCancelOrder {
                return strongSelf.interactor.cancelOrder(order: order).map {.orderDidFinishCancel($0)}.asSignal(onErrorSignalWith: Signal.empty())
            }
            
            return strongSelf.interactor.myOrders().map {.setOrders($0)}.asSignal(onErrorSignalWith: Signal.empty())
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
                
                $0.isNeedCancelOrder = false
                $0.isNeedLoadOrders = false

                $0.section.items.removeAll()
                for order in orders {
                    $0.section.items.append(DexMyOrders.ViewModel.Row.order(order))
                }                
            }.changeAction(.update)
            
        case .orderDidFinishCancel(let response):
            return state.mutate {
                $0.isNeedCancelOrder = false
                $0.isNeedLoadOrders = false

                switch response.result {
                
                case .success:
                    $0.action = .orderDidFinishCancel
                    
                case .error(let error):
                    if let order = state.canceledOrder, let index = $0.section.items.index(where: {$0.order?.id == order.id}) {
                        $0.section.items[index] = DexMyOrders.ViewModel.Row.order(order)
                    }
                    $0.action = .orderDidFailCancel(error)
                }

            }
            
        case .cancelOrder(let indexPath):
            
            return state.mutate {
                
                $0.isNeedLoadOrders = false

                if let order = state.section.items[indexPath.row].order {

                    $0.canceledOrder = order
                    $0.isNeedCancelOrder = true
                    
                    var newOrder = order
                    newOrder.status = .cancelled
                    
                    $0.section.items[indexPath.row] = DexMyOrders.ViewModel.Row.order(newOrder)
                    $0.action = .update
                }
                else {
                    $0.action = .none
                }
            }
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
        return DexMyOrders.State(action: .none, section: section, isNeedLoadOrders: false, isNeedCancelOrder: false, canceledOrder: nil)
    }
}
