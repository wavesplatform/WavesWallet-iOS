//
//  DexMarketTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation


enum DexMarket {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case readyView
        case setPairs([DTO.Pair])
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

extension DexMarket.DTO {
    
    struct Asset: Hashable {
        let id: String
        let name: String
        let shortName: String
        let decimals: Int
    }
    
    struct Pair: Mutating {
        let id: String
        let amountAsset: Asset
        let priceAsset: Asset
        var isChecked: Bool
        let isGeneral: Bool
        
        init(amountAsset: Asset, priceAsset: Asset, isChecked: Bool, isGeneral: Bool) {
            
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
            self.isChecked = isChecked
            self.isGeneral = isGeneral
            self.id = amountAsset.id + priceAsset.id
        }
    }
}

