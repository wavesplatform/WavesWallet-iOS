//
//  AddressBookTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AddressBookTypes {
    enum ViewModel {}
    
    enum Event {
        case readyView
        case setUsers([DomainLayer.DTO.User])
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
        var section: AddressBookTypes.ViewModel.Section
    }
}

extension AddressBookTypes.ViewModel {

    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case user(DomainLayer.DTO.User)
        
        var user: DomainLayer.DTO.User {
            switch self {
            case .user(let user):
                return user
            }
        }
    }
}

extension AddressBookTypes.ViewModel.Section {
    
    var isEmpty: Bool {
        return items.count == 0
    }
}
