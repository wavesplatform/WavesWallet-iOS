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
        case setModels(ResponseType<[DTO.Pair]>)
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
        let sortLevel: Int
    }
    
    private static func precisionDifference(_ amountDecimals: Int, _ priceDecimals: Int) -> Int {
        return priceDecimals - amountDecimals + 8
    }
    
    static func price(amount: Int64, amountDecimals: Int, priceDecimals: Int) -> Money {
        
        let precisionDiff = precisionDifference(amountDecimals, priceDecimals)
        let decimalValue = Decimal(amount) / pow(10, precisionDiff)

        return Money((decimalValue * pow(10, priceDecimals)).int64Value, priceDecimals)
    }
    
    static func priceAmount(price: Money, amountDecimals: Int, priceDecimals: Int) -> Int64 {
        let precisionDiff = precisionDifference(amountDecimals, priceDecimals)
        return (price.decimalValue * pow(10, precisionDiff)).int64Value
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
