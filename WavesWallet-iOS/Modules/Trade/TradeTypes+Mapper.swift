//
//  TradeSystem+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 24.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import WavesSDK

extension TradeTypes.DTO.Core {
    
    func mapCategories(selectedFilters: [TradeTypes.DTO.SelectedFilter]) -> [TradeTypes.DTO.Category] {
        
                                        
        var uiCategories: [TradeTypes.DTO.Category] = []
        var favoritePairsPrice: [TradeTypes.DTO.Pair] = []
               
        let rates = pairsRate.reduce(into: [String: Money].init(), {
            $0[$1.amountAssetId] = Money(value: Decimal($1.rate), WavesSDKConstants.FiatDecimals)
        })
           
        for pair in favoritePairs {
                   
            if let pairPrice = pairsPrice.first(where: {$0.amountAsset.id == pair.amountAssetId &&
                $0.priceAsset.id == pair.priceAssetId}) {

                let priceUSD = rates[pairPrice.amountAsset.id] ?? Money(0, 0)
                    
                favoritePairsPrice.append(.init(id: pairPrice.id,
                                                amountAsset: pairPrice.amountAsset,
                                                priceAsset: pairPrice.priceAsset,
                                                firstPrice: pairPrice.firstPrice,
                                                lastPrice: pairPrice.lastPrice,
                                                isFavorite: true,
                                                priceUSD: priceUSD))
            }
        }
               
        if favoritePairsPrice.count == 0 {
            uiCategories.append(.init(index: 0,
                                      isFavorite: true,
                                      name: "",
                                      header: nil,
                                      rows: [.emptyData]))
        }
        else {
            uiCategories.append(.init(index: 0,
                                      isFavorite: true,
                                      name: "",
                                      header: nil,
                                      rows: favoritePairsPrice.map {.pair($0)}))
        }
                                            
        for (index, category) in categories.enumerated() {

            var categoryPairs: [TradeTypes.DTO.Pair] = []
                
            for pair in category.pairs {
                       
                if let pairPrice = pairsPrice.first(where: {$0.amountAsset == pair.amountAsset &&
                    $0.priceAsset == pair.priceAsset}) {

                    let priceUSD = rates[pairPrice.amountAsset.id] ?? Money(0, 0)
                    let isFavorite = favoritePairs.contains(where: {$0.id == pairPrice.id})
                            
                    categoryPairs.append(.init(id: pairPrice.id,
                                                amountAsset: pairPrice.amountAsset,
                                                priceAsset: pairPrice.priceAsset,
                                                firstPrice: pairPrice.firstPrice,
                                                lastPrice: pairPrice.lastPrice,
                                                isFavorite: isFavorite,
                                                priceUSD: priceUSD))
                }
            }
                
                    
            let categoryIndex = index + 1
            let selectedFilter = selectedFilters.first(where: {$0.categoryIndex == categoryIndex})
                
            var header: TradeTypes.ViewModel.Header? {
                if category.filters.count > 0 {
                    return .filter(.init(categoryIndex: categoryIndex,
                                         selectedFilter: nil, //selectedFilter?.filter,
                                            filters: category.filters))
                }
            
                return nil
            }
                
            uiCategories.append(.init(index: categoryIndex,
                                      isFavorite: false,
                                      name: category.name,
                                      header: header,
                                      rows: categoryPairs.map {.pair($0)}))
        }
            
        return uiCategories
    }
    
}
