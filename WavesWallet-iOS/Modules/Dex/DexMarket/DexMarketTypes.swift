//
//  DexMarketTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions


enum DexMarket {
    enum ViewModel {}
    enum DTO {}
    
    enum Event {
        case readyView
        case setPairs([DomainLayer.DTO.Dex.SmartPair])
        case tapCheckMark(index: Int)
        case tapInfoButton(index: Int)
        case searchTextChange(text: String)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var action: Action
        var section: DexMarket.ViewModel.Section
        var searchKey: String
        var isNeedSearching: Bool
        var isNeedLoadDefaultPairs: Bool
    }
}

extension DexMarket.DTO {
    
    struct Input {
        let selectedAsset: DomainLayer.DTO.Dex.Asset?
        let delegate: TradeRefreshOutput?
    }
    
    struct Pair {
        let smartPair: DomainLayer.DTO.Dex.SmartPair
        let selectedAsset: DomainLayer.DTO.Dex.Asset?
    }
}

extension DexMarket.ViewModel {
   
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case pair(DexMarket.DTO.Pair)
    }
    
}

extension DexMarket.State: Equatable {
    static func == (lhs: DexMarket.State, rhs: DexMarket.State) -> Bool {
        return lhs.isNeedSearching == rhs.isNeedSearching &&
            lhs.searchKey == rhs.searchKey &&
            lhs.isNeedLoadDefaultPairs == rhs.isNeedLoadDefaultPairs
    }
}
