//
//  DexListModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

//TODO: - Refactor, use asset from DomainLayer.DTO.Asset
private enum FiatAsset {
    static let USD = "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck"
    static let EUR = "Gtb1WRznfchDnTh37ezoDTJ4wcoKaRsKqKjJjy7nm2zU"
    static let TRY = "2mX5DzVKWrAJw8iwdJnV2qtoeVG9h5nTDpTqC1wb1WEN"
}

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
        
        var isAppear: Bool
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
    
    enum Row {
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
    
    struct Pair: Mutating {
        var firstPrice: Money
        var lastPrice: Money
        let amountAsset: Dex.DTO.Asset
        let priceAsset: Dex.DTO.Asset
        let isGeneral: Bool
    }
    
    static let fiatAssets: [String] = {
        return [FiatAsset.USD, FiatAsset.EUR, FiatAsset.TRY]
    }()
}

extension DexList.State {
    var isVisibleItems: Bool {
        return sections.count > 1
    }
}

extension DexList.State : Equatable {
    
    static func == (lhs: DexList.State, rhs: DexList.State) -> Bool {
        return lhs.isAppear == rhs.isAppear &&
        lhs.isNeedRefreshing == rhs.isNeedRefreshing
    }
}
