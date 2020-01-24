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
import DomainLayer

extension TradeTypes.DTO.Core {
    
    func mapCategories(selectedFilters: [TradeTypes.DTO.SelectedFilter], selectedAsset: DomainLayer.DTO.Dex.Asset?) -> [TradeTypes.DTO.Category] {
        
                                        
        var uiCategories: [TradeTypes.DTO.Category] = []
        var favoritePairsPrice: [TradeTypes.DTO.Pair] = []
               
        let rates = pairsRate.reduce(into: [String: Money].init(), {
            $0[$1.amountAssetId] = Money(value: Decimal($1.rate), WavesSDKConstants.FiatDecimals)
        })
           
        for pair in favoritePairs {
                   
            if let pairPrice = pairsPrice.first(where: {$0.amountAsset.id == pair.amountAssetId &&
                $0.priceAsset.id == pair.priceAssetId}) {

                if let asset = selectedAsset {
                    let contain = pair.amountAssetId == asset.id || pair.priceAssetId == asset.id
                    if !contain {
                        continue
                    }
                }
                
                let priceUSD = rates[pairPrice.amountAsset.id] ?? Money(0, 0)
                    
                favoritePairsPrice.append(.init(id: pairPrice.id,
                                                isGeneral: pairPrice.isGeneral,
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

            let categoryIndex = index + 1
            let selectedFilter = selectedFilters.first(where: {$0.categoryIndex == categoryIndex})

            for pair in category.pairs {
                       
                if let pairPrice = pairsPrice.first(where: {$0.amountAsset == pair.amountAsset &&
                    $0.priceAsset == pair.priceAsset}) {

                    if let selectedFilter = selectedFilter {
                        if !selectedFilter.filter.ids.contains(pairPrice.amountAsset.id) &&
                            !selectedFilter.filter.ids.contains(pairPrice.priceAsset.id) {
                            continue
                        }
                    }
                    
                    if let asset = selectedAsset {
                        let contain = pair.amountAsset.id == asset.id || pair.priceAsset.id == asset.id
                        if !contain {
                            continue
                        }
                    }
                    
                    let priceUSD = rates[pairPrice.amountAsset.id] ?? Money(0, 0)
                    let isFavorite = favoritePairs.contains(where: {$0.id == pairPrice.id})
                            
                    categoryPairs.append(.init(id: pairPrice.id,
                                               isGeneral: pairPrice.isGeneral,
                                               amountAsset: pairPrice.amountAsset,
                                               priceAsset: pairPrice.priceAsset,
                                               firstPrice: pairPrice.firstPrice,
                                               lastPrice: pairPrice.lastPrice,
                                               isFavorite: isFavorite,
                                               priceUSD: priceUSD))
                }
            }
                
                
            var header: TradeTypes.ViewModel.Header? {
                if category.filters.count > 0 {
                    return .filter(.init(categoryIndex: categoryIndex,
                                         selectedFilter: selectedFilter?.filter,
                                            filters: category.filters))
                }
            
                return nil
            }
                
            if categoryPairs.count == 0 {
                uiCategories.append(.init(index: categoryIndex,
                                          isFavorite: false,
                                          name: category.name,
                                          header: header,
                                          rows: [.emptyData]))
            }
            else {
                uiCategories.append(.init(index: categoryIndex,
                                          isFavorite: false,
                                          name: category.name,
                                          header: header,
                                          rows: categoryPairs.map {.pair($0)}))
            }
        }
            
        return uiCategories
    }
    
}
