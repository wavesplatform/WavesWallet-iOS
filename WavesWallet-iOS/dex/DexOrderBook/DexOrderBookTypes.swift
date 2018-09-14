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
        case didTapEmptyBid
        case didTapAsk(DTO.BidAsk)
        case didTamEmptyAsk
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
            case scrollTableToCenter
        }
        
        var action: Action
        var sections: [DexOrderBook.ViewModel.Section]
        var header: DexOrderBook.ViewModel.Header
        var hasFirstTimeLoad: Bool
        var isNeedRefreshing: Bool
    }
}

extension DexOrderBook.ViewModel {
   
    struct Header {
        let amountName: String
        let priceName: String
        let sumName: String
    }
    
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
        let price: Money
        let percent: Float
        let orderType: OrderType
    }
    
    struct BidAsk {
        let price: Money
        let amount: Money
        let sum: Money
        let orderType: OrderType
        let percentAmount: Float
    }
    
    struct DisplayData {
        let asks: [BidAsk]
        let lastPrice: LastPrice
        let bids: [BidAsk]
        let header: DexOrderBook.ViewModel.Header
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
        return DexOrderBook.DTO.LastPrice(price: Money(0, 0), percent: 0, orderType: .none)
    }
}

//MARK: - State
extension DexOrderBook.State {
  
    static var initialState: DexOrderBook.State {
        let header = DexOrderBook.ViewModel.Header(amountName: "", priceName: "", sumName: "")
        return DexOrderBook.State(action: .none, sections: [], header: header, hasFirstTimeLoad: false, isNeedRefreshing: false)
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


