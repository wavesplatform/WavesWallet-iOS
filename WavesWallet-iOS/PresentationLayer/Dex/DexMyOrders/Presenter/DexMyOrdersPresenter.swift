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
        
        return react(query: { state -> Bool? in
            return state.isAppeared ? true : nil
        }, effects: { [weak self] ss -> Signal<DexMyOrders.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            
            return strongSelf.interactor.myOrders().map {.setOrders($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexMyOrders.State, event: DexMyOrders.Event) -> DexMyOrders.State {
        
        switch event {
        case .readyView:
            return state.mutate {
                $0.isAppeared = true
            }.changeAction(.none)
        
        case .setOrders(let orders):
          
            return state.mutate {
                
                var section = DexMyOrders.ViewModel.Section(items: [])
                
                for order in orders {
                    section.items.append(DexMyOrders.ViewModel.Row.order(order))
                }
               
                $0.section = section
                
            }.changeAction(.update)
            
        case .didRemoveOrder(let indexPath):
            
            if let order = state.section.items[indexPath.row].order {
                interactor.deleteOrder(order: order)
            }
            
            return state.mutate {

                $0.section.items.remove(at: indexPath.row)
                $0.action = .deleteRow(indexPath)
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
        return DexMyOrders.State(action: .none, section: section, isAppeared: false)
    }
}
