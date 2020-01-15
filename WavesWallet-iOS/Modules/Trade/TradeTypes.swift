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

enum TradeTypes {
    enum DTO {}
    enum ViewModel {}

    enum Event {
        case readyView
    }
    
    struct State: Mutating {
        enum UIAction {
            case none
            case update
        }
                 
        enum CoreAction: Equatable {
            case none
            case loadPairs
            case favouriteTapped
        }
        
        var uiAction: UIAction
        var coreAction: CoreAction
    }
}

extension TradeTypes.DTO {
    
    struct Pair {
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        let amountAssetIcon: AssetLogo.Icon
        let priceAssetIcon: AssetLogo.Icon
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
    
    struct Section {
        var favorites: [TradeTypes.DTO.Pair]
    }
}


extension TradeTypes.State: Equatable {
    
    static func == (lhs: TradeTypes.State, rhs: TradeTypes.State) -> Bool {
        return lhs.coreAction == rhs.coreAction
    }
}
