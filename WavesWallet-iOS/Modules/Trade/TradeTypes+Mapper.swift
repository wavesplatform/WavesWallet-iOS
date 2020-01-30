//
//  TradeSystem+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 24.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import Foundation
import Extensions
import WavesSDK
import DomainLayer

extension TradeTypes.DTO.Core {
    
    func mapCategories(selectedFilters: [TradeTypes.DTO.SelectedFilter], selectedAsset: DomainLayer.DTO.Dex.Asset?) -> [TradeTypes.DTO.Category] {
        
        let rates = pairsRate.reduce(into: [String: Money].init(), {
            $0[$1.amountAssetId] = Money(value: Decimal($1.rate), WavesSDKConstants.FiatDecimals)
        })

        let pairsPriceMap = pairsPrice.reduce(into: [String : DomainLayer.DTO.Dex.PairPrice].init(), {
            $0[$1.id] = $1
        })
            
        let favoritePairsMap = favoritePairs.reduce(into: [String: Bool].init(), {
            $0[$1.id] = true
        })
        
        let selectedFiltersMap = selectedFilters.reduce(into: [Int: TradeTypes.DTO.SelectedFilter].init(), {
            $0[$1.categoryIndex] = $1
        })
        
        var uiCategories = [mapFavoriteCategory(selectedAsset: selectedAsset, rates: rates, pairsPriceMap: pairsPriceMap)]
        var favoritePairsPrice: [TradeTypes.DTO.Pair] = []
            
        for (index, category) in categories.enumerated() {

            var categoryPairs: [TradeTypes.DTO.Pair] = []

            let categoryIndex = index + 1
            let selectedFilter = selectedFiltersMap[categoryIndex]

            for pair in category.pairs {
                       
                if let pairPrice = pairsPriceMap[pair.id] {

                    if let asset = selectedAsset {
                        let contain = pair.amountAsset.id == asset.id || pair.priceAsset.id == asset.id
                        if !contain {
                            continue
                        }
                    }
                    
                    if let selectedFilter = selectedFilter, selectedFilter.filters.count > 0 {
                        
                        if selectedFilter.filters.first(where: {$0.ids.contains(pairPrice.amountAsset.id)}) == nil &&
                            selectedFilter.filters.first(where: {$0.ids.contains(pairPrice.priceAsset.id)}) == nil {
                            continue
                        }
                    }
                    
                    let priceUSD = rates[pairPrice.amountAsset.id] ?? Money(0, 0)
                    
                    categoryPairs.append(.init(id: pairPrice.id,
                                               isGeneral: pairPrice.isGeneral,
                                               amountAsset: pairPrice.amountAsset,
                                               priceAsset: pairPrice.priceAsset,
                                               firstPrice: pairPrice.firstPrice,
                                               lastPrice: pairPrice.lastPrice,
                                               isFavorite: favoritePairsMap[pairPrice.id] == true,
                                               priceUSD: priceUSD))
                }
            }
                
                
            var header: TradeTypes.ViewModel.Header? {
                if category.filters.count > 0 {
                    return .filter(.init(categoryIndex: categoryIndex,
                                         selectedFilters: selectedFilter?.filters ?? [],
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

private extension TradeTypes.DTO.Core {
    
    func mapFavoriteCategory(selectedAsset: DomainLayer.DTO.Dex.Asset?, rates: [String: Money], pairsPriceMap: [String: DomainLayer.DTO.Dex.PairPrice]) -> TradeTypes.DTO.Category {
        
        var favoritePairsPrice: [TradeTypes.DTO.Pair] = []
        
        for pair in favoritePairs {
                   
            if let pairPrice = pairsPriceMap[pair.id] {

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
            return .init(index: 0,
                         isFavorite: true,
                         name: "",
                         header: nil,
                         rows: [.emptyData])
        }
        else {
            return .init(index: 0,
                         isFavorite: true,
                         name: "",
                         header: nil,
                         rows: favoritePairsPrice.map {.pair($0)})
        }
    }
}