//
//  NewAccountTypes.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum NewAccountTypes {
    enum DTO { }
}

extension NewAccountTypes.DTO {
        struct Account {
            let privateKey: PrivateKeyAccount
            let password: String
            let name: String
        }
}
