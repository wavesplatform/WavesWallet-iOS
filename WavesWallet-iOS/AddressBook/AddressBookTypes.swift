//
//  AddressBookTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AddressBook {
    enum DTO {}
    enum ViewModel {}
    
    
    enum Event {
        case readyView
        case setUsers([DTO.User])
        case tapCheckEdit(index: Int)
        case searchTextChange(text: String)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var isAppeared: Bool
        var action: Action
        var section: AddressBook.ViewModel.Section
    }
}

extension AddressBook.ViewModel {

    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case user(AddressBook.DTO.User)
        
        var user: AddressBook.DTO.User {
            switch self {
            case .user(let user):
                return user
            }
        }
    }
}

extension AddressBook.DTO {

    struct User {
        let name: String
        let address: String
    }    
}
