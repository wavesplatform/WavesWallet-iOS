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

    weak var moduleOutput: TransactionHistoryModuleOutput?
    let moduleInput: TransactionHistoryModuleInput
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let addressBook: AddressBookRepositoryProtocol = FactoryRepositories.instance.addressBookRepository
    
    init(input: TransactionHistoryModuleInput) {
        moduleInput = input
    }
    
    func system(feedbacks: [TransactionHistoryPresenterProtocol.Feedback]) {
        
        var newFeedbacks = feedbacks
        newFeedbacks.append(showAddressBookFeedback())
        newFeedbacks.append(cancelLeasingFeedback())
//        newFeedbacks.append(updateAddressBookFeedback())

        Driver.system(initialState: TransactionHistoryPresenter.initialState(transactions: moduleInput.transactions, currentIndex: moduleInput.currentIndex),
                      reduce: { [weak self] state, event in self?.reduce(state: state, event: event) ?? state },
                      feedback: newFeedbacks)
            .drive()
            .disposed(by: disposeBag)
    }

//    func updateAddressBookFeedback() -> TransactionHistoryPresenterProtocol.Feedback {
//
//        return react(query: { state -> Bool in
//            return state.isAppeared == true
//
//        }, effects: { [weak self] _ -> Signal<Event> in
//
//
//        })
//        .asSignal(onErrorJustReturn: .completedAction)
//
//    }

    func showAddressBookFeedback() -> TransactionHistoryPresenterProtocol.Feedback {

        return react(query: { state -> (DomainLayer.DTO.Account, Bool)? in

            switch state.action {
            case .showAddressBook(let account, let isAdded):
                return (account, isAdded)
            default:
                return nil
            }

        }, effects: { [weak self] data -> Signal<Event> in

            return Observable.create({ [weak self] (observer) -> Disposable in

                let account = data.0
                let isAdded = data.1

                let finished: TransactionHistoryModuleOutput.FinishedAddressBook = { (contact, isOK) in
                    if isOK {
                        observer.onNext(.updateContact(contact))
                    } else {
                        observer.onNext(.completedAction)
                    }
                }

                if let contact = account.contact, isAdded == false {
                    self?.moduleOutput?.transactionHistoryEditAddressToHistoryBook(contact: contact, finished: finished)
                } else {
                    self?.moduleOutput?.transactionHistoryAddAddressToHistoryBook(address: account.address, finished: finished)
                }
                return Disposables.create()
            }).asSignal(onErrorJustReturn: .completedAction)
        })
    }

    func cancelLeasingFeedback() -> TransactionHistoryPresenterProtocol.Feedback {

        return react(query: { state -> (DomainLayer.DTO.SmartTransaction)? in

            switch state.action {
            case .cancelLeasing(let tx):
                return tx
            default:
                return nil
            }

        }, effects: { [weak self] data -> Signal<Event> in

            self?.moduleOutput?.transactionHistoryCancelLeasing(data)
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

        case .setContacts(_):
            break

        case .readyView:
            break

        case .updateContact(let contactState):

            let contact = contactState.contact
            let needDelete = contactState.needDelete

            let newDisplays = state.displays.reduce(into: [Types.DisplayState]() ) { (displays, display) in

                let newSections = display.sections.reduce(into: [Types.ViewModel.Section](), { (sections, section) in

                    let newItems = section.items.reduce(into: [Types.ViewModel.Row](), { (rows, row) in


                        if case let .recipient(recipient) = row,
                            recipient.account.address == contact.address
                        {
                            let newAccount = DomainLayer.DTO.Account(address: recipient.account.address,
                                                                     contact: needDelete == true ? nil : contact,
                                                                     isMyAccount: recipient.account.isMyAccount)

                            rows.append(.recipient(Types.ViewModel.Recipient(kind: recipient.kind,
                                                                             account: newAccount,
                                                                             amount: recipient.amount,
                                                                             isHiddenTitle: recipient.isHiddenTitle)))
                        } else {
                            rows.append(row)
                        }
                    })
                    var newSection = section
                    newSection.items = newItems
                    sections.append(newSection)
                })

                var newDisplay = display
                newDisplay.sections = newSections
                displays.append(newDisplay)
            }

            state.displays = newDisplays
            state.actionDisplay = .reload(index: nil)
            state.action = .none

        case .tapRecipient(_, let recipient):
            
            let isAdded = recipient.account.contact == nil            
            state.action = .showAddressBook(account: recipient.account, isAdded: isAdded)
            state.actionDisplay = .none

        case .tapButton(let display):

            switch display.transaction.kind {
            case .startedLeasing:
                state.action = .cancelLeasing(transaction: display.transaction)

            case .selfTransfer, .sent:
                state.action = .resendTransaction(display.transaction)

            default:
                state.action = .none
            }

            state.actionDisplay = .none

        case .completedAction:
            state.action = .none
            state.actionDisplay = .none
        case .setContacts(_):
            break
        }
    }
    
    private static func initialState(transactions: [DomainLayer.DTO.SmartTransaction], currentIndex: Int) -> TransactionHistoryTypes.State {
        return TransactionHistoryTypes.State.initialState(transactions: transactions, currentIndex: currentIndex)
    }
}
