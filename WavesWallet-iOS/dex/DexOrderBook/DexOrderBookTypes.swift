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
        case setDisplayData(DTO.DisplayData)
        case tapSellButton
        case tapBuyButton
    }
    
    
    struct State: Mutating {
        enum Action {
            case none
            case update
            case scrollTableToCenter
        }
        
        var action: Action
        var sections: [DexOrderBook.ViewModel.Section]
        var sellTitle: String = "—"
        var buyTitle: String = "—"
        var hasFirstTimeLoad: Bool
    }
}

extension DexOrderBook.ViewModel {
   
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case bid(DexOrderBook.DTO.BidAsk)
        case ask(DexOrderBook.DTO.BidAsk)
        case lastPrice(DexOrderBook.DTO.LastPrice)
    }
}

extension DexOrderBook.ViewModel.Row {
    
    var lastPrice: DexOrderBook.DTO.LastPrice? {
        switch self {
        case .lastPrice(let price):
            return price
        default:
            return nil
        }
    }
}

extension DexOrderBook.DTO {

    enum OrderType {
        case none
        case sell
        case buy
    }
    
    struct LastPrice {
        let price: Double
        let percent: Float
        let orderType: OrderType
    }
    
    struct BidAsk {
        let price: Money
        let amount: Money
        let orderType: OrderType
        let percentAmount: Float
        let defaultScaleDecimal: Int = 8
    }
    
    struct DisplayData {
        let asks: [BidAsk]
        let bids: [BidAsk]
        let lastPrice: LastPrice
    }
}
