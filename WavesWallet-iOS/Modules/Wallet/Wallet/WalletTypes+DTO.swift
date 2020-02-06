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
            let total: Money
        }
        
        struct Payout {
            let money: Money
            let date: Date
        }
        
        struct Landing {
            let percent: Double
            let minimumDeposit: Money
        }
        
        struct Balance {
            let total: Money
            let available: Money
            let inStaking: Money
        }
        
        let profit: Profit
        let balance: Balance
        let lastPayouts: [Payout]
        var landing: Landing?
    }
}
