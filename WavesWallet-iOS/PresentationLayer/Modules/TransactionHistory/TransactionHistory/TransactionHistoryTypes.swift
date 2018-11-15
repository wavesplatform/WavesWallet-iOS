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
    }

    struct DisplayState: Mutating {
        var transaction: DomainLayer.DTO.SmartTransaction
        var sections: [ViewModel.Section]
    }
    
    enum Event {
        case readyView
        case tapRecipient(DisplayState, ViewModel.Recipient)
        case completedAction
    }

    enum Action {
        case none
        case showAddressBook(account: DomainLayer.DTO.Account, isAdded: Bool)
    }
}

