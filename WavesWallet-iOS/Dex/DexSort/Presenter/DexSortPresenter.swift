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

protocol DexSortPresenterProtocol {
    typealias Feedback = (Driver<DexSort.State>) -> Signal<DexSort.Event>
    
    func system(feedbacks: [Feedback])
}

final class DexSortPresenter: DexSortPresenterProtocol {
    
    private let interactor: DexSortInteractorProtocol = DexSortInteractorMock()
    private let disposeBag = DisposeBag()

    
    func system(feedbacks: [DexSortPresenterProtocol.Feedback]) {
        
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        
        Driver.system(initialState: DexSort.State.initialState,
                      reduce: reduce,
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
            if let model = state.section.items[indexPath.row].model {
                interactor.delete(model: model)
            }

            return state.deleteRow(indexPath: indexPath).changeAction(.delete)

        case .dragModels(let sourceIndexPath, let destinationIndexPath):

            let movableModel = state.section.items[sourceIndexPath.row].model
            let toModel = state.section.items[destinationIndexPath.row].model
            
            if let movableModel = movableModel, let toModel = toModel {
                if sourceIndexPath.row > destinationIndexPath.row {
                    interactor.move(model: movableModel, overModel: toModel)
                } else {
                    interactor.move(model: movableModel, underModel: toModel)
                }
            }

            return state.moveRow(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath).changeAction(.refresh)
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
    
    func moveRow(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) -> DexSort.State {
        
        return mutate { state in
            let section = state.section.moveRow(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
            state.section = section
        }
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
    
    func moveRow(sourceIndex: Int, destinationIndex: Int) -> DexSort.ViewModel.Section {
        return mutate { section in
            let row = section.items.remove(at: sourceIndex)
            section.items.insert(row, at: destinationIndex)
        }
    }
    
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
    var model: DexSort.DTO.DexSortModel? {
        switch self {
        case .model(let model):
            return model
        }
    }
}

