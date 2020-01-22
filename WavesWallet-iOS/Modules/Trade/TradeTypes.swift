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
            case updateSkeleton(ViewModel.SectionSkeleton)
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
        let firstPrice: Money
        let lastPrice: Money
        let isFavorite: Bool
        let priceUSD: Money
    }
    
    struct Category {
        let isFavorite: Bool
        let name: String
        let filters: [DomainLayer.DTO.TradeCategory.Filter]
        let rows: [TradeTypes.ViewModel.Row]
    }
}

extension TradeTypes.ViewModel {
  
    struct SectionSkeleton {
        var rows: [RowSkeleton]
    }

    enum RowSkeleton {
        case defaultCell
        case headerCell
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
