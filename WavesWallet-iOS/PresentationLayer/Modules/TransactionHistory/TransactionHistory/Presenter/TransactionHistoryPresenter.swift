//
//  TransactionHistoryPresenter.swift
//  WavesWallet-iOS
//
//  Created by Mac on 27/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxCocoa

protocol TransactionHistoryPresenterProtocol {
    typealias Feedback = (Driver<TransactionHistoryTypes.State>) -> Signal<TransactionHistoryTypes.Event>
    
    func system(feedbacks: [Feedback])
}

final class TransactionHistoryPresenter: TransactionHistoryPresenterProtocol {

    typealias Types = TransactionHistoryTypes
    typealias Event = Types.Event

    var interactor: TransactionHistoryInteractorProtocol!
    weak var moduleOutput: TransactionHistoryModuleOutput?
    let moduleInput: TransactionHistoryModuleInput
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(input: TransactionHistoryModuleInput) {
        moduleInput = input
    }
    
    func system(feedbacks: [TransactionHistoryPresenterProtocol.Feedback]) {
        
        var newFeedbacks = feedbacks
        newFeedbacks.append(handlerAction())
        
        Driver.system(initialState: TransactionHistoryPresenter.initialState(transactions: moduleInput.transactions, currentIndex: moduleInput.currentIndex),
                      reduce: { [weak self] state, event in self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }


    func handlerAction() -> TransactionHistoryPresenterProtocol.Feedback {

        return react(query: { state -> Bool? in

            switch state.action {
            case .showAddressBook(let account, let isAdded):

                if let contact = account.contact, isAdded == false {
                    self.moduleOutput?.transactionHistoryEditAddressToHistoryBook(contact: contact, finished: { (contact, isOK) in

                    })
                } else {
                    self.moduleOutput?.transactionHistoryAddAddressToHistoryBook(address: account.address, finished: { (contact, isOk) in

                    })
                }

                return true
            default:
                return nil
            }

        }, effects: { _ -> Signal<Event> in
            return Signal.just(.completedAction)
        })
    }

    
    private func reduce(state: TransactionHistoryTypes.State, event: TransactionHistoryTypes.Event) -> TransactionHistoryTypes.State {
        var newState = state
        reduce(state: &newState, event: event)
        return newState
    }

    private func reduce(state: inout TransactionHistoryTypes.State, event: TransactionHistoryTypes.Event) {

        switch event {
        case .readyView:
            break

        case .tapRecipient(_, let recipient):
            
            let isAdded = recipient.account.contact == nil            
            state.action = .showAddressBook(account: recipient.account, isAdded: isAdded)

        case .completedAction:
            state.action = .none
        }
    }
    
    private static func initialState(transactions: [DomainLayer.DTO.SmartTransaction], currentIndex: Int) -> TransactionHistoryTypes.State {
        return TransactionHistoryTypes.State.initialState(transactions: transactions, currentIndex: currentIndex)
    }
}
