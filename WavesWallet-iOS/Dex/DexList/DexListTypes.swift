//
//  DexListModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexList {
    enum DTO {}
    enum ViewModel {}

    enum Event {
        case readyView
        case setModels([DTO.Pair])
        case tapSortButton
        case tapAddButton
        case refresh
        case tapAssetPair(DTO.Pair)
    }
    
    struct State: Mutating {
        
        enum Action {
            case none
            case update
        }
        
        var isNeedRefreshing: Bool
        var action: Action
        var sections: [DexList.ViewModel.Section]
        var isFirstLoadingData: Bool
        var lastUpdate: Date
    }
}

extension DexList.ViewModel {
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row: Hashable {
        case header(Date)
        case skeleton
        case model(DexList.DTO.Pair)
        
        var model: DexList.DTO.Pair? {
            switch self {
            case .model(let model):
                return model
            default:
                return nil
            }
        }
    }
}

extension DexList.DTO {
    
    struct Asset: Hashable  {
        let id: String
        let name: String
        let decimals: Int
        let ticker: String
    }
    
    struct Pair: Hashable, Mutating {
        var firstPrice: Money
        var lastPrice: Money
        let amountAsset: Asset
        let priceAsset: Asset
        let isHidden: Bool
    }
}

extension DexList.State {
    var isVisibleItems: Bool {
        return sections.count > 1
    }
}
