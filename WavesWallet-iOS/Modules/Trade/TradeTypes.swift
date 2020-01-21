//
//  TradeTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import DomainLayer
import WavesSDK

enum TradeTypes {
    enum DTO {}
    enum ViewModel {}

    enum Event {
        case readyView
        case categoriesDidLoad([DTO.Category])
        case didFailGetCategories(NetworkError)
        case refresh
    }
    
    struct State {
        
        enum UIAction {
            case none
            case update
            case didFailGetError(NetworkError)
        }
                 
        enum CoreAction: Equatable {
            case none
            case loadCategories
            case favouriteTapped
        }
        
        var uiAction: UIAction
        var coreAction: CoreAction
        var categories: [DTO.Category]
    }
}

extension TradeTypes.DTO {
    
    struct Pair {
        let id: String
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        var firstPrice: Money
        var lastPrice: Money
        let isFavorite: Bool
    }
    
    struct Category {
        let isFavorite: Bool
        let name: String
        let filters: [DomainLayer.DTO.TradeCategory.Filter]
        let pairs: [Pair]
    }
}

extension TradeTypes.ViewModel {
    
    enum State: Int {
        case favorite
        case btc
        case waves
        case alts
        case fiat
    }
    
    struct Section: Mutating {
           var allItems: [Row]
           var activeItems: [Row]
           var closedItems: [Row]
           var canceledItems: [Row]

           static var empty: Section {
               return .init(allItems: [],
                            activeItems: [],
                            closedItems: [],
                            canceledItems: [])
           }
       }

    enum Row {
        case pair(TradeTypes.DTO.Pair)
        case emptyData
    }
}


extension TradeTypes.State: Equatable {
    
    static func == (lhs: TradeTypes.State, rhs: TradeTypes.State) -> Bool {
        return lhs.coreAction == rhs.coreAction
    }
}
