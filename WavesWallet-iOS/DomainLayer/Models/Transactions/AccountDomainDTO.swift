//
//  AccountDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct Account {
        
        let id: String
        let contact: DomainLayer.DTO.Contact?
        let isMyAccount: Bool
    }
}
