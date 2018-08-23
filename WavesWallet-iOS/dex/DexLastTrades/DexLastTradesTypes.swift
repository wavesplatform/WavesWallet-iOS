//
//  DexLastTradesTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexLastTrades {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case readyView
        case setTrades([DTO.Trade])
        case didTapSell(DTO.SellBuyTrade)
        case didTapEmptySell
        case didTapBuy(DTO.SellBuyTrade)
        case didTapEmptyBuy
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var action: Action
        var section: DexLastTrades.ViewModel.Section
        var lastSell: DTO.SellBuyTrade?
        var lastBuy: DTO.SellBuyTrade?
        var hasFirstTimeLoad: Bool
    }
}


extension DexLastTrades.ViewModel {
    
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case trade(DexLastTrades.DTO.Trade)
    }
}


extension DexLastTrades.DTO {
    
    enum TradeType {
        case sell
        case buy
    }
    
    struct Trade {
        let time: Date
        let price: Money
        let amount: Money
        let sum: Money
        let type: TradeType
    }
    
    struct SellBuyTrade {
        let price: Money
        let type: TradeType
    }
}

extension DexLastTrades.State {
    static var initialState: DexLastTrades.State {
        let section = DexLastTrades.ViewModel.Section(items: [])
        return DexLastTrades.State(action: .none, section: section, lastSell: nil, lastBuy: nil, hasFirstTimeLoad: false)
    }
    
    var isNotEmpty: Bool {
        return section.items.count > 0
    }
}
