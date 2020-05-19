//
//  InvestmentStakingVM.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import WavesSDKExtensions

struct InvestmentStakingVM {
    struct Profit {
        let percent: Double
        let total: DomainLayer.DTO.Balance
    }

    struct Landing {
        let percent: Double
        let minimumDeposit: DomainLayer.DTO.Balance
    }

    struct Balance: Hashable {
        var total: DomainLayer.DTO.Balance
        var available: DomainLayer.DTO.Balance
        var inStaking: DomainLayer.DTO.Balance
    }

    let accountAddress: String
    let profit: Profit
    var balance: Balance
    let lastPayouts: PayoutsHistoryState.MassTransferTrait
    let neutrinoAsset: Asset?
    var landing: Landing?
}
