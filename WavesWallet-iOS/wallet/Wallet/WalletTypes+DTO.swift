//
//  WalletTypes+DTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension WalletTypes.DTO {

    struct Asset: Hashable {
        enum Kind: Hashable {
            case gateway
            case fiatMoney
            case wavesToken
        }

        enum State: Hashable {
            case none
            case general
            case favorite
            case hidden
            case spam
        }

        let id: String
        let name: String
        let balance: Money
        let fiatBalance: Money
        let king: Kind
        let state: State
        let level: Float
    }
}
