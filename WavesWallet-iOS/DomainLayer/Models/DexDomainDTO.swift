//
//  DexTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/12/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    enum Dex {}
}

//MARK: Asset
extension DomainLayer.DTO.Dex {
    
    struct Asset {
        let id: String
        let name: String
        let shortName: String
        let decimals: Int
    }
    
    enum OrderType: String {
        case sell
        case buy
    }
}

//MARK: LastTrade
extension DomainLayer.DTO.Dex {
    
    struct LastTrade {
        let time: Date
        let price: Money
        let amount: Money
        let sum: Money
        let type: OrderType
    }
}

//MARK: - SmartPair
extension DomainLayer.DTO.Dex {
    
    struct SmartPair: Mutating {
        let id: String
        let amountAsset: Asset
        let priceAsset: Asset
        var isChecked: Bool
        let isGeneral: Bool
        var sortLevel: Int
    }
}

//MARK: - Pair
extension DomainLayer.DTO.Dex {
    
    struct Pair {
        let amountAsset: Asset
        let priceAsset: Asset
    }
}

//MARK: - PairPrice
extension DomainLayer.DTO.Dex {
    struct PairPrice {
        let firstPrice: Money
        let lastPrice: Money
        let amountAsset: Asset
        let priceAsset: Asset
    }
}
