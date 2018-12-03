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
        case setAssets([DomainLayer.DTO.SmartAssetBalance])
        case searchTextChange(text: String)
        case didSelectAsset(DomainLayer.DTO.SmartAssetBalance)
        case changeMyList(Bool)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case update
        }
        
        var isAppeared: Bool
        var action: Action
        var section: ViewModel.Section
        var isMyList: Bool
    }
}


extension AssetList.ViewModel {
    
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case asset(DomainLayer.DTO.SmartAssetBalance)
        
        var asset: DomainLayer.DTO.SmartAssetBalance {
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
        let selectedAsset: DomainLayer.DTO.SmartAssetBalance?
        let showAllList: Bool
    }
    
    enum Filter {
        case all
        case cryptoCurrency
        case fiat
        case waves
        case wavesToken
        case spam
    }
}

extension AssetList.State: Equatable {
    
     static func == (lhs: AssetList.State, rhs: AssetList.State) -> Bool {
        return lhs.isAppeared == rhs.isAppeared &&
               lhs.isMyList == rhs.isMyList
    }
}

extension AssetList.ViewModel.Section {
    var isEmptyAssetsBalance: Bool {
        return items.filter({$0.asset.balance > 0}).count == 0
    }
}
