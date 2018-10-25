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
            let contact: DomainLayer.DTO.Contact?
            let address: String?
        }
    }
}
