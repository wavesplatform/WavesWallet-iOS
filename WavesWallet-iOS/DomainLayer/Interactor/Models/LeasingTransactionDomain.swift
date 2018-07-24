//
//  LeasingTransaction.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct Leasing {
        let balance: AssetBalance
        let transaction: [LeasingTransaction]
    }
}
