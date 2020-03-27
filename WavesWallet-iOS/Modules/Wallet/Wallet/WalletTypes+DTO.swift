//
//  WalletTypes+DTO.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import Extensions
import DomainLayer

extension WalletTypes.DTO {

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
    
    
    struct Staking {
        
        struct Profit {
            let percent: Double 
            let total: DomainLayer.DTO.Balance
        }
        
        struct Landing {
            let percent: Double
            let minimumDeposit: DomainLayer.DTO.Balance
        }
        
        struct Balance {
            let total: DomainLayer.DTO.Balance
            let available: DomainLayer.DTO.Balance
            let inStaking: DomainLayer.DTO.Balance
        }
        
        let profit: Profit
        let balance: Balance
        let lastPayouts: PayoutsHistoryState.MassTransferTrait
        let neutrinoAsset: DomainLayer.DTO.Asset?
        var landing: Landing?
    }
}
