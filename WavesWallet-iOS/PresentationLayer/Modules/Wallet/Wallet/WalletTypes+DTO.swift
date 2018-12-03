//
//  WalletTypes+DTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension WalletTypes.DTO {

    struct Asset {
   
        let id: String
        let name: String
        let issuer: String
        let description: String
        let issueDate: Date
        let balance: Money
        let fiatBalance: Money
        let isReusable: Bool
        let isMyWavesToken: Bool
        let isWavesToken: Bool
        let isWaves: Bool
        let isHidden: Bool
        let isFavorite: Bool
        let isSpam: Bool
        let isFiat: Bool
        let isGateway: Bool
        let sortLevel: Float
        let icon: String
        let assetBalance: DomainLayer.DTO.SmartAssetBalance
    }

    struct Leasing {

        struct Balance: Hashable {
            let totalMoney: Money
            let avaliableMoney: Money
            let leasedMoney: Money
            let leasedInMoney: Money
        }

        let balance: Balance
        let transactions: [DomainLayer.DTO.SmartTransaction]
    }
}
