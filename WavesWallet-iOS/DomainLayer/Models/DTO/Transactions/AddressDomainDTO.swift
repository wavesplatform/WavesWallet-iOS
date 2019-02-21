//
//  AccountDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct Address: Hashable {
        
        let address: String
        let contact: DomainLayer.DTO.Contact?
        let isMyAccount: Bool
        let aliases: [DomainLayer.DTO.Alias]
    }
}
