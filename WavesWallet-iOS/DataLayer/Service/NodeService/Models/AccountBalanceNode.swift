//
//  AddressBalanceNodeService.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.Model {
    struct AccountBalance: Decodable {
        let address: String
        let confirmations: Int64
        let balance: Int64
    }
}
