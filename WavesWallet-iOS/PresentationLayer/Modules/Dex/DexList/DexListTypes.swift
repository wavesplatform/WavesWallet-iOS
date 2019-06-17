//
//  DexListModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer
import Extensions

enum DexList {
    enum DTO {}
    enum ViewModel {}

    enum Event {
        case readyView
        case viewWillAppear
        case setDisplayInfo(ResponseType<DTO.DisplayInfo>)
        case setLocalDisplayInfo(DTO.LocalDisplayInfo)
        case tapSortButton(DexListRefreshOutput)
        case tapAddButton(DexListRefreshOutput)
        case refresh
        case refreshBackground
        case tapAssetPair(DTO.Pair)
        case didChangeAssets
        case updateSortLevel
    }
    
    struct State: Mutating {
        
        enum Action {
            case none
            case update
            case didFailGetModels(NetworkError)
        }
        
        var isNeedRefreshing: Bool
        var isNeedRefreshingBackground: Bool
        var isNeedUpdateSortLevel: Bool
        var action: Action
        var sections: [DexList.ViewModel.Section]
        var isFirstLoadingData: Bool
        var lastUpdate: Date
        var errorState: DisplayErrorState
        var authWalletError: Bool
        var hasChangeAssets: Bool
    }
}

extension DexList.ViewModel {
    struct Section: Mutating {
        var items: [Row]
        
        var isHeaderSection: Bool {
            return items.filter{ (row) -> Bool in
                switch row {
                case .header:
                    return true
                    
                default:
                    return false
                }
            }.count > 0
        }
        
        var isModelSection: Bool {
            return items.filter{ (row) -> Bool in
                switch row {
                case .model:
                    return true
                    
                default:
                    return false
                }
            }.count > 0
        }
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
    
    struct LocalDisplayInfo {
        let pairs: [DomainLayer.DTO.Dex.SmartPair]
        let authWalletError: Bool
    }
    
    struct DisplayInfo {
        let pairs: [Pair]
        let authWalletError: Bool
    }
    
    struct Pair: Mutating {
        let id: String
        var firstPrice: Money
        var lastPrice: Money
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        let isGeneral: Bool
        var sortLevel: Int
    }
}

extension DexList.State {
    var isVisibleItems: Bool {
        return sections.count > 0
    }
}

extension DexList.State : Equatable {
    
    static func == (lhs: DexList.State, rhs: DexList.State) -> Bool {
        return lhs.isNeedRefreshing == rhs.isNeedRefreshing &&
        lhs.isNeedRefreshingBackground == rhs.isNeedRefreshingBackground &&
        lhs.isNeedUpdateSortLevel == rhs.isNeedUpdateSortLevel
    }
}
