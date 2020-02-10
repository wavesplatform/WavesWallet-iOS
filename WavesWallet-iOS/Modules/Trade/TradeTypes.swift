//
//  TradeTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
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
        case favoritePairsDidLoad([DomainLayer.DTO.Dex.FavoritePair])
        case didFailGetCategories(NetworkError)
        case refresh
        case refresIfNeed
        case favoriteTapped(DTO.Pair)
        case favoriteDidSuccessRemove
        case favoriteDidSuccessSave([DomainLayer.DTO.Dex.FavoritePair])
        case filterTapped(TradeTypes.DTO.Category.Filter, atCategory: Int)
        case deleteFilter(atCategory: Int)
    }
    
    struct State {
        
        enum UIAction {
            case none
            case update(initialCurrentIndex: Int?)
            case deleteRowAt(IndexPath)
            case reloadRowAt(IndexPath)
            case updateSkeleton(ViewModel.SectionSkeleton)
            case didFailGetError(NetworkError)
        }
                 
        enum CoreAction: Equatable {
            case none
            case loadData(DomainLayer.DTO.Dex.Asset?)
            case loadFavoritePairs
            case removeFromFavorite(String)
            case saveToToFavorite(DTO.Pair)
        }
        
        var uiAction: UIAction
        var coreAction: CoreAction
        var core: DTO.Core
        var categories: [ViewModel.Category]
        var selectedFilters: [TradeTypes.DTO.SelectedFilter]
        var selectedAsset: DomainLayer.DTO.Dex.Asset?
    }
}

extension TradeTypes.DTO {
    
    struct SelectedFilter: Equatable {
        let categoryIndex: Int
        var filters: [TradeTypes.DTO.Category.Filter]
    }
    
    struct Filter {
        let categoryIndex: Int
        let selectedFilters: [TradeTypes.DTO.Category.Filter]
        let filters: [TradeTypes.DTO.Category.Filter]
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
        let volumeWaves: Double
        let selectedAsset: DomainLayer.DTO.Dex.Asset?
    }
            
    struct Core {
        var pairsPrice: [DomainLayer.DTO.Dex.PairPrice]
        var pairsRate: [DomainLayer.DTO.Dex.PairRate]
        var favoritePairs: [DomainLayer.DTO.Dex.FavoritePair]
        var categories: [TradeTypes.DTO.Category]
    }
         
    struct Category {
        
        public struct Filter: Equatable {
            public let name: String
            public let ids: [String]
            
            public init(name: String, ids: [String]) {
                self.name = name
                self.ids = ids
            }
        }
        
        public let name: String
        public let filters: [Filter]
        public let pairs: [DomainLayer.DTO.Dex.Pair]
                            
        public init(name: String,
                    filters: [Filter],
                    pairs: [DomainLayer.DTO.Dex.Pair]) {
            
            self.name = name
            self.filters = filters
            self.pairs = pairs
        }
    }
}

extension TradeTypes.ViewModel {
  
    struct Category {
        let index: Int
        let isFavorite: Bool
        let name: String
        let header: TradeTypes.ViewModel.Header?
        var rows: [TradeTypes.ViewModel.Row]
    }
    
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

extension Array where Element == TradeTypes.ViewModel.Category {

    func category(_ tableView: UITableView) -> TradeTypes.ViewModel.Category {
        return self[tableView.tag]
    }
}
