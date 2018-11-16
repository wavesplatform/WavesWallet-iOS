//
//  TransactionHistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by Mac on 22/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

enum TransactionHistoryTypes {
    enum DTO {}
    enum ViewModel {}

    struct State: Mutating {
        
        var currentIndex: Int
        var action: Action
        var displays: [DisplayState]
        var transactions: [DomainLayer.DTO.SmartTransaction]
        var actionDisplay: ActionDisplay
    }

    struct DisplayState: Mutating {
        var transaction: DomainLayer.DTO.SmartTransaction
        var sections: [ViewModel.Section]
    }
    
    enum Event {
        case readyView
        case tapRecipient(DisplayState, ViewModel.Recipient)
        case completedAction
        case updateContact(DTO.ContactState)
    }

    enum ActionDisplay {
        case none
        case reload(index: Int?)
    }

    enum Action {
        case none
        case showAddressBook(account: DomainLayer.DTO.Account, isAdded: Bool)
    }
}

extension TransactionHistoryTypes.DTO {
    enum ContactState {
        case update(DomainLayer.DTO.Contact)
        case delete(DomainLayer.DTO.Contact)

        var needDelete: Bool {
            switch self {
            case .update:
                return false

            case .delete:
                return true
            }
        }

        var contact: DomainLayer.DTO.Contact {

            switch self {
            case .update(let contact):
                return contact

            case .delete(let contact):
                return contact
            }
        }
    }
}
