//
//  InvestmentLeasingVM.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import WavesSDKExtensions

struct InvestmentLeasingVM {
    struct Balance: Hashable {
        let totalMoney: Money
        let avaliableMoney: Money
        let leasedMoney: Money
        let leasedInMoney: Money
    }

    let balance: Balance
    let transactions: [SmartTransaction]
}
