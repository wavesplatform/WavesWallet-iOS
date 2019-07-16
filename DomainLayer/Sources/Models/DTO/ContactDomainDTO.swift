//
//  AddressBookDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct Contact: Hashable {
        public let name: String
        public let address: String

        public init(name: String, address: String) {
            self.name = name
            self.address = address
        }
    }
}
