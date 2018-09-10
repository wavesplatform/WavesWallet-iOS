//
//  DexSellBuyTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexSellBuy {
    enum DTO {}
    enum ViewModel {}
    
}

extension DexSellBuy.ViewModel {
    
}

extension DexSellBuy.DTO {
    enum OrderType {
        case sell
        case buy
    }
    
    struct Order {
        let type: OrderType
        let amount: Double
        let price: Double
    }
}
