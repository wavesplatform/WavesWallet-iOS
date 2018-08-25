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
                      reduce: reduce,
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        
        
        return react(query: { state -> Bool? in
            return true
        }, effects: { [weak self] ss -> Signal<DexMyOrders.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            
            return strongSelf.interactor.myOrders().map {.setOrders($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: DexMyOrders.State, event: DexMyOrders.Event) -> DexMyOrders.State {
        
        switch event {
        case .readyView:
            return state.changeAction(.none)
        
        case .setOrders(let orders):
          
            return state.mutate {
                
                var sections: [DexMyOrders.ViewModel.Section] = []
                
                for order in orders {

                    let row = DexMyOrders.ViewModel.Row.order(order)
                    if let index = sections.index(where: {
                        $0.header.date.year == order.time.year &&
                        $0.header.date.month == order.time.month &&
                        $0.header.date.day == order.time.day}) {

                        sections[index].items.append(row)
                    }
                    else {
                        let header = DexMyOrders.ViewModel.Header(date: order.time)
                        sections.append(DexMyOrders.ViewModel.Section(items: [row], header: header))
                    }
                }
               
                $0.sections = sections
                
            }.changeAction(.update)
            
        case .didRemoveOrder(let indexPath):
            
            return state.mutate {

                $0.sections[indexPath.section].items.remove(at: indexPath.row)
                
                var deletedSection: Int?
                if let emptySectionIndex = $0.sections.index(where: {$0.items.count == 0}) {
                    $0.sections.remove(at: emptySectionIndex)
                    deletedSection = emptySectionIndex
                }
                
                if let section = deletedSection {
                    $0.deletedSection = section
                    $0.deletedIndexPath = nil
                }
                else {
                    $0.deletedSection = nil
                    $0.deletedIndexPath = indexPath
                }
             }.changeAction(.delete)
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
        return DexMyOrders.State(action: .none, sections: [], deletedIndexPath: nil, deletedSection: nil)
    }
}
