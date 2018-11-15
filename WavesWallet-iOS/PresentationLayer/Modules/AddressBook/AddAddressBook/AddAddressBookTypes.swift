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
                case edit(contact: DomainLayer.DTO.Contact, isMutable: Bool)
                case add(String?, isMutable: Bool)
            }
            let kind: Kind
        }
    }
}

extension AddAddressBook.DTO.Input {

    var isAdd: Bool {        
        switch self.kind {
        case .add:
            return true
        default:
            return false
        }
    }

    var contact: DomainLayer.DTO.Contact? {
        switch self.kind {
        case .edit(let contact, _):
            return contact
        default:
            return nil
        }
    }
}
