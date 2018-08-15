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
            case general
            case hidden
            case spam
        }

        let id: String
        let name: String
        let balance: Money
        let fiatBalance: Money
        let isMyWavesToken: Bool
        let isFavorite: Bool
        let isFiat: Bool
        let isGateway: Bool
        let isWaves: Bool
        let kind: Kind
        let sortLevel: Float
    }

    struct Leasing: Hashable {

        struct Transaction: Hashable {
            let id: String
            let balance: Money
        }

        struct Balance: Hashable {
            let totalMoney: Money
            let avaliableMoney: Money
            let leasedMoney: Money
            let leasedInMoney: Money
        }

        let balance: Balance
        let transactions: [Transaction]
    }
}
