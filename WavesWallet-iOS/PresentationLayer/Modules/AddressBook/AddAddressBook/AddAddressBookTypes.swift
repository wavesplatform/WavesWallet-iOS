//
//  AddAddressBookTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AddAddressBook {
    
    enum DTO {
        struct Input {
            enum Kind {
                case edit(address: String)
                case add
            }
            let kind: Kind
        }
    }
}

extension AddAddressBook.DTO.Input {

    var isAdd: Bool {        
        switch self {
        case .add:
            return true
        default:
            return false
        }
    }
}
