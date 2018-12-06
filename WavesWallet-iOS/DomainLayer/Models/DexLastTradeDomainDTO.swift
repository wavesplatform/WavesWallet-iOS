//
//  DexLastTrade.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
   
    struct DexLastTrade {
        let time: Date
        let price: Money
        let amount: Money
        let sum: Money
        let type: Dex.DTO.OrderType
    }
}
