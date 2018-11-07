//
//  DexSortPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa


final class DexSortPresenter: DexSortPresenterProtocol {
    
    var interactor: DexSortInteractorProtocol!
    private let disposeBag = DisposeBag()

    
    func system(feedbacks: [DexSortPresenterProtocol.Feedback]) {
        
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexSort.State.initialState,
                      reduce: { [weak self] state, event -> DexSort.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return state.isNeedRefreshing == true ? true : nil
        }, effects: { [weak self] _ -> Signal<DexSort.Event> in

            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.models().map { .setModels($0) }.asSignal(onErrorSignalWith: Signal.empty())
        })
    }

    private func reduce(state: DexSort.State, event: DexSort.Event) -> DexSort.State {

        switch event {
        case .readyView:
            return state.mutate { $0.isNeedRefreshing = true }

        case .tapDeleteButton(let indexPath):

            interactor.delete(model: state.section.items[indexPath.row].model)
            return state.deleteRow(indexPath: indexPath).changeAction(.delete)

        case .dragModels(let sourceIndexPath, let destinationIndexPath):

            return state.mutate {
                let row = $0.section.items.remove(at: sourceIndexPath.row)
                $0.section.items.insert(row, at: destinationIndexPath.row)
                
                for (index, row) in $0.section.items.enumerated() {
                    $0.section.items[index] = DexSort.ViewModel.Row.model(row.model.mutate { $0.sortLevel = index + 1})
                }
                
                interactor.update($0.section.items.map {$0.model})
                
            }.changeAction(.none)
            

        case .setModels(let models):
            
            return state.mutate { state in
                state.isNeedRefreshing = false
                state.section = DexSort.ViewModel.map(from: models)
                }.changeAction(.refresh)
        }
    }
}

fileprivate extension DexSort.State {
    static var initialState: DexSort.State {
        return DexSort.State(isNeedRefreshing: false, action: .none, section: DexSort.ViewModel.Section(items: []), deletedIndex: 0)
    }
    
    func deleteRow(indexPath: IndexPath) -> DexSort.State {
        return mutate { state in
            let section = state.section.deleteRow(index: indexPath.row)
            state.section = section
            state.deletedIndex = indexPath.row
        }
    }
    
    func changeAction(_ action: DexSort.State.Action) -> DexSort.State {

        return mutate { state in
            state.action = action
        }
    }
}

private extension DexSort.ViewModel.Section {
    
    
    func deleteRow(index: Int) -> DexSort.ViewModel.Section {
        return mutate { section in
            section.items.remove(at: index)
        }
    }
}

private extension DexSort.ViewModel {
    static func map(from models: [DexSort.DTO.DexSortModel]) -> DexSort.ViewModel.Section {
        
        let sortedModels = models.sorted(by: { $0.sortLevel < $1.sortLevel })
            .map { DexSort.ViewModel.Row.model($0) }

        return DexSort.ViewModel.Section(items: sortedModels)
    }
}


private extension DexSort.ViewModel.Row {
    var model: DexSort.DTO.DexSortModel {
        switch self {
        case .model(let model):
            return model
        }
    }
}

