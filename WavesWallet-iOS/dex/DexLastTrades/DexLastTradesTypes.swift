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
        case setDisplayData(DTO.DisplayData)
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
        var isNeedRefreshing: Bool
        var availableAmountAssetBalance: Money
        var availablePriceAssetBalance: Money

    }
}


extension DexLastTrades.ViewModel {
    
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case trade(DexLastTrades.DTO.Trade)
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}


extension DexLastTrades.DTO {
   
    struct Trade {
        let time: Date
        let price: Money
        let amount: Money
        let sum: Money
        let type: Dex.DTO.OrderType
    }
    
    struct SellBuyTrade {
        let price: Money
        let type: Dex.DTO.OrderType
    }
    
    struct DisplayData {
        let trades: [Trade]
        let lastSell: SellBuyTrade?
        let lastBuy: SellBuyTrade?
        let availableAmountAssetBalance: Money
        let availablePriceAssetBalance: Money
    }
}

extension DexLastTrades.State {
    static var initialState: DexLastTrades.State {
        let section = DexLastTrades.ViewModel.Section(items: [])
        return DexLastTrades.State(action: .none, section: section, lastSell: nil, lastBuy: nil, hasFirstTimeLoad: false, isNeedRefreshing: false,
                                   availableAmountAssetBalance: Money(0, 0),
                                   availablePriceAssetBalance: Money(0, 0))
    }
    
    var isNotEmpty: Bool {
        return section.items.count > 0
    }
}
