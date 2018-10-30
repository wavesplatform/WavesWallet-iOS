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
    
    struct Pair: Mutating {
        let id: String
        let amountAsset: Dex.DTO.Asset
        let priceAsset: Dex.DTO.Asset
        var isChecked: Bool
        let isGeneral: Bool
        var sortLevel: Int
    }
}

extension DexMarket.DTO.Pair {

    
    init(_ pair: DexAssetPair, isChecked: Bool) {
        
        let amountAsset = Dex.DTO.Asset(id: pair.amountAsset.id,
                                        name: pair.amountAsset.name,
                                        shortName: pair.amountAsset.shortName,
                                        decimals: pair.amountAsset.decimals)
        
        let priceAsset = Dex.DTO.Asset(id: pair.priceAsset.id,
                                       name: pair.priceAsset.name,
                                       shortName: pair.priceAsset.shortName,
                                       decimals: pair.priceAsset.decimals)
        
        
        self.amountAsset = amountAsset
        self.priceAsset = priceAsset
        self.isChecked = isChecked
        self.isGeneral = pair.isGeneral
        self.sortLevel = pair.sortLevel
        self.id = pair.id
        
    }
}
