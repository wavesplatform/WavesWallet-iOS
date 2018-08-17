//
//  DexOrderBookTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexOrderBook {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case readyView
        case setBids([DTO.BidAsk])
        case setAsks([DTO.BidAsk])
        case setLastPrice(DTO.LastPrice)
        case tapSellButton
        case tapBuyButton
//        case refresh
    }
    
    
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var action: Action
//        var section: DexMarket.ViewModel.Section
    }
}

extension DexMarket.ViewModel {
    
}

extension DexOrderBook.DTO {
    
    enum OrderType {
        case sell
        case buy
    }
    
    struct LastPrice {
        let price: Int64
        let percent: Float
        let orderType: OrderType
    }
    
    struct BidAsk {
        let price: Int64
        let amount: Int64
        let amountAssetDecimal: Int
        let priceAssetDecimal: Int
        let orderType: OrderType
        let percentAmount: Float
        let defaultScaleDecimal: Int = 8
    }
}
