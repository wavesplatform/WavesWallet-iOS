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
        case setDisplayInfo(ResponseType<DTO.DisplayInfo>)
        case tapSortButton(DexListRefreshOutput)
        case tapAddButton(DexListRefreshOutput)
        case refresh
        case tapAssetPair(DTO.Pair)
    }
    
    struct State: Mutating {
        
        enum Action {
            case none
            case update
            case didFailGetModels(NetworkError)
        }
        
        var isAppear: Bool
        var isNeedRefreshing: Bool
        var action: Action
        var sections: [DexList.ViewModel.Section]
        var isFirstLoadingData: Bool
        var lastUpdate: Date
        var errorState: DisplayErrorState
        var authWalletError: Bool
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
    
    struct DisplayInfo {
        let pairs: [Pair]
        let authWalletError: Bool
    }
    
    struct Pair: Mutating {        
        var firstPrice: Money
        var lastPrice: Money
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        let isGeneral: Bool
        let sortLevel: Int
    }
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
