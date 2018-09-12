//
//  DexSellBuyTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexCreateOrder {
    enum DTO {}    
}

extension DexCreateOrder.DTO {
  
    enum OrderType {
        case sell
        case buy
    }
    
    struct Input {
        let amountAsset: Dex.DTO.Asset
        let priceAsset: Dex.DTO.Asset
        let type: OrderType
        let price: Money
    }
    
    struct Balance {
        let totalMoney: Money
    }
}
