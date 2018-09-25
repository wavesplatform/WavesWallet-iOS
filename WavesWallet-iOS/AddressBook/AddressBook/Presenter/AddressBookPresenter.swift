//
//  AddressBookPresenter.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

final class AddressBookPresenter: AddressBookPresenterProtocol {
    
    var interactor: AddressBookInteractorProtocol!
    
    private let disposeBag = DisposeBag()

    
    func system(feedbacks: [AddressBookPresenterProtocol.Feedback]) {
        var newFeedbacks = feedbacks
        newFeedbacks.append(modelsQuery())
        newFeedbacks.append(searchModelsQuery())
        
        Driver.system(initialState: AddressBook.State.initialState,
                      reduce: { [weak self] state, event -> AddressBook.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return true
        }, effects: { [weak self] _ -> Signal<AddressBook.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.getAllUsers().map {.setUsers($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func searchModelsQuery() -> Feedback {
        return react(query: { state -> Bool? in
            return state.isAppeared ? true : nil
        }, effects: { [weak self] _ -> Signal<AddressBook.Event> in
            
            // TODO: Error
            guard let strongSelf = self else { return Signal.empty() }
            
            return strongSelf.interactor.getSearchUsers().map {.setUsers($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: AddressBook.State, event: AddressBook.Event) -> AddressBook.State {
        
        switch event {
        case .readyView:
            return state.mutate {
                $0.isAppeared = true
            }.changeAction(.none)

        case .setUsers(let users):
            return state.mutate {
                
                let items = users.map { AddressBook.ViewModel.Row.user($0) }
                let section = AddressBook.ViewModel.Section(items: items)
                $0.section = section
                
            }.changeAction(.update)
            
        case .searchTextChange(let text):
            interactor.searchUser(searchText: text)
            return state.changeAction(.none)

        case .tapCheckEdit(let index):
            
            return state
        }
    }
}

fileprivate extension AddressBook.State {
    
    static var initialState: AddressBook.State {
        let section = AddressBook.ViewModel.Section(items: [])
        return AddressBook.State(isAppeared: false, action: .none, section: section)
    }
    
    func changeAction(_ action: AddressBook.State.Action) -> AddressBook.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
