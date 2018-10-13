//
//  AssetListTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AssetList {
    
    enum DTO {}
    enum ViewModel {}
    
    
    enum Event {
        case readyView
        case setAssets([DomainLayer.DTO.AssetBalance])
        case searchTextChange(text: String)
        case didSelectAsset(DomainLayer.DTO.AssetBalance)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var isAppeared: Bool
        var action: Action
        var section: ViewModel.Section
    }
}


extension AssetList.ViewModel {
    
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case asset(DomainLayer.DTO.AssetBalance)
        
        var asset: DomainLayer.DTO.AssetBalance {
            switch self {
            case .asset(let asset):
                return asset
            }
        }
    }
}

extension AssetList.DTO {
    
    struct Input {
        let filters: [AssetList.DTO.Filter]
        let selectedAsset: DomainLayer.DTO.AssetBalance?
    }
    
    enum Filter {
        case all
        case cryptoCurrency
        case fiat
        case waves
        case wavesToken
    }
}
