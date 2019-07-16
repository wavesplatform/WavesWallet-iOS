//
//  AccountDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public extension DomainLayer.DTO {
    struct Address: Hashable {
        
        public let address: String
        public let contact: DomainLayer.DTO.Contact?
        public let isMyAccount: Bool
        public let aliases: [DomainLayer.DTO.Alias]

        public init(address: String, contact: DomainLayer.DTO.Contact?, isMyAccount: Bool, aliases: [DomainLayer.DTO.Alias]) {
            self.address = address
            self.contact = contact
            self.isMyAccount = isMyAccount
            self.aliases = aliases
        }
    }
}
