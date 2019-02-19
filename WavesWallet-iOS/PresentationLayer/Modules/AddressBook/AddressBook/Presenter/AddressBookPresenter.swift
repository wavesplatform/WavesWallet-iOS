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
        
        Driver.system(initialState: AddressBookTypes.State.initialState,
                      reduce: { [weak self] state, event -> AddressBookTypes.State in
                        return self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func modelsQuery() -> Feedback {
        return react(request: { state -> Bool? in
            return state.isAppeared ? true : nil
        }, effects: { [weak self] _ -> Signal<AddressBookTypes.Event> in
            
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.interactor.users().map {.setContacts($0)}.asSignal(onErrorSignalWith: Signal.empty())
        })
    }
    
    private func reduce(state: AddressBookTypes.State, event: AddressBookTypes.Event) -> AddressBookTypes.State {
        
        switch event {
        case .readyView:
            return state.mutate {
                $0.isAppeared = true
            }.changeAction(.none)

        case .setContacts(let contacts):
            return state.mutate {
                
                let items = contacts.map { AddressBookTypes.ViewModel.Row.contact($0) }
                let section = AddressBookTypes.ViewModel.Section(items: items)
                $0.section = section
                
            }.changeAction(.update)
            
        case .searchTextChange(let text):
            interactor.searchUser(searchText: text)
            return state.changeAction(.none)
        }

    }
}

fileprivate extension AddressBookTypes.State {
    
    static var initialState: AddressBookTypes.State {
        let section = AddressBookTypes.ViewModel.Section(items: [])
        return AddressBookTypes.State(isAppeared: false, action: .none, section: section)
    }
    
    func changeAction(_ action: AddressBookTypes.State.Action) -> AddressBookTypes.State {
        
        return mutate { state in
            state.action = action
        }
    }
}
