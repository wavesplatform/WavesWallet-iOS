//
//  AddressBookModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol AddressBookModuleOutput: AnyObject {
    func addressBookDidSelectUser(_ user: AddressBook.DTO.User)
    func addressBookDidEditUser(_ user: AddressBook.DTO.User)
}

extension AddressBookModuleOutput {
   
    func addressBookDidSelectUser(_ user: AddressBook.DTO.User) {

    }

    func addressBookDidEditUser(_ user: AddressBook.DTO.User) {

    }
}
