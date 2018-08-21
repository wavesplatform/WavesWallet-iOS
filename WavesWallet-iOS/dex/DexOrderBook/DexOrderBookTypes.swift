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
        case didTapBid(DTO.BidAsk)
        case didTapAsk(DTO.BidAsk)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
            case scrollTableToCenter
        }
        
        var action: Action
        var sections: [DexOrderBook.ViewModel.Section]
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

//MARK: - DTO
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
        let defaultScaleDecimal: Int = 8

        let price: Money
        let amount: Money
        let sum: Money
        let orderType: OrderType
        let percentAmount: Float

        var priceText: String {
            return MoneyUtil.getScaledText(price.amount, decimals: price.decimals, scale: defaultScaleDecimal + price.decimals - amount.decimals)
        }
    }
    
    struct DisplayData {
        let asks: [BidAsk]
        let lastPrice: LastPrice
        let bids: [BidAsk]
    }
}

//MARK: - Row
extension DexOrderBook.ViewModel.Row {
    
    var lastPrice: DexOrderBook.DTO.LastPrice? {
        switch self {
        case .lastPrice(let price):
            return price
        default:
            return nil
        }
    }
    
    var bid: DexOrderBook.DTO.BidAsk? {
        switch self {
        case .bid(let bid):
            return bid
        default:
            return nil
        }
    }
    
    var ask: DexOrderBook.DTO.BidAsk? {
        switch self {
        case .ask(let ask):
            return ask
        default:
            return nil
        }
    }
}


//MARK: - LastPrice
extension DexOrderBook.DTO.LastPrice {
    static var empty: DexOrderBook.DTO.LastPrice {
        return DexOrderBook.DTO.LastPrice(price: 0, percent: 0, orderType: .none)
    }
}

//MARK: - State
extension DexOrderBook.State {
  
    static var initialState: DexOrderBook.State {
        return DexOrderBook.State(action: .none, sections: [], hasFirstTimeLoad: false)
    }
    
    var lastBid: DexOrderBook.DTO.BidAsk? {
        return sections.first(where: {
            $0.items.filter({$0.bid != nil}).count > 0
        })?.items.first?.bid
    }
    
    var lastAsk: DexOrderBook.DTO.BidAsk? {
        return sections.first(where: {
            $0.items.filter({$0.ask != nil}).count > 0
        })?.items.last?.ask
    }
    
    var isNotEmpty: Bool {
        return sections.filter({$0.items.count > 0}).count > 0
    }
    
    var lastPriceSection: Int? {
        return sections.index(where: {$0.items.filter({$0.lastPrice != nil}).count > 0})
    }
}


