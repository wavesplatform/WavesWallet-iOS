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
        case dataDidLoad(DTO.Core)
        case didFailGetCategories(NetworkError)
        case refresh
        case favoriteTapped(DTO.Pair)
        case favoriteDidSuccessRemove
        case favoriteDidSuccessSave([DomainLayer.DTO.Dex.FavoritePair])
        case filterTapped(DomainLayer.DTO.TradeCategory.Filter, atCategory: Int)
    }
    
    struct State {
        
        enum UIAction {
            case none
            case update
            case deleteRowAt(IndexPath)
            case reloadRowAt(IndexPath)
            case updateSkeleton(ViewModel.SectionSkeleton)
            case didFailGetError(NetworkError)
        }
                 
        enum CoreAction: Equatable {
            case none
            case loadData
            case removeFromFavorite(String)
            case saveToToFavorite(DTO.Pair)
        }
        
        var uiAction: UIAction
        var coreAction: CoreAction
        var core: DTO.Core
        var categories: [DTO.Category]
        var selectedFilters: [DTO.SelectedFilter]
    }
}

extension TradeTypes.DTO {
    
    struct SelectedFilter {
        let categoryIndex: Int
        let filter: DomainLayer.DTO.TradeCategory.Filter
    }
    
    struct Filter {
        let categoryIndex: Int
        let selectedFilter: DomainLayer.DTO.TradeCategory.Filter?
        let filters: [DomainLayer.DTO.TradeCategory.Filter]
    }
    
    struct Input {
        let selectedAsset: DomainLayer.DTO.Dex.Asset?
        let output: TradeModuleOutput
    }
    
    struct Pair: Equatable {
        let id: String
        let isGeneral: Bool
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        let firstPrice: Money
        let lastPrice: Money
        var isFavorite: Bool
        let priceUSD: Money
    }
    
    struct Category {
        let index: Int
        let isFavorite: Bool
        let name: String
        let header: TradeTypes.ViewModel.Header?
        var rows: [TradeTypes.ViewModel.Row]
    }
    
    struct Core {
        var pairsPrice: [DomainLayer.DTO.Dex.PairPrice]
        var pairsRate: [DomainLayer.DTO.Dex.PairRate]
        var favoritePairs: [DomainLayer.DTO.Dex.FavoritePair]
        var categories: [DomainLayer.DTO.TradeCategory]
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
        
        
        var pair: TradeTypes.DTO.Pair? {
            
            switch self {
            case .pair(let pair):
                return pair
            default:
                return nil
            }
        }
    }
    
    enum Header {
        case filter(TradeTypes.DTO.Filter)
    }
}

extension Array where Element == TradeTypes.ViewModel.Row {
    
    var pairs: [TradeTypes.DTO.Pair] {
        
        var newPairs: [TradeTypes.DTO.Pair] = []
        for row in self {
            if let pair = row.pair {
                newPairs.append(pair)
            }
        }
        return newPairs
    }
}

extension TradeTypes.ViewModel.Header {
    
    var filter: TradeTypes.DTO.Filter {
        switch self {
        case .filter(let filter):
            return filter
        }
    }
}

extension TradeTypes.State: Equatable {
    
    static func == (lhs: TradeTypes.State, rhs: TradeTypes.State) -> Bool {
        return lhs.coreAction == rhs.coreAction
    }
}

extension Array where Element == TradeTypes.DTO.Category {

    func category(_ tableView: UITableView) -> TradeTypes.DTO.Category {
        return self[tableView.tag]
    }
}
