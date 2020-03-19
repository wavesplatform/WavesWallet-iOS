//
//  NewAccountTypes.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer

enum NewAccountTypes {
    enum DTO { }
}

extension NewAccountTypes.DTO {
        struct Account {
            let privateKey: DomainLayer.DTO.PrivateKey
            let password: String
            let name: String            
        }
}
