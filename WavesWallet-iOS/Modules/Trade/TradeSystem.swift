//
//  TradeSystem.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa
import Extensions
import DomainLayer
import WavesSDK

private enum Constants {
    // Current id is USD-N
    static let usdAssetId = "DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p"
}

final class TradeSystem: System<TradeTypes.State, TradeTypes.Event> {
    
    private let tradeCategoriesRepository = UseCasesFactory.instance.repositories.tradeCategoriesConfigRepository
    private let dexRealmRepository = UseCasesFactory.instance.repositories.dexRealmRepository
    private let pairsPriceRepository = UseCasesFactory.instance.repositories.dexPairsPriceRepository
    private let auth: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    
    private let selectedAsset: DomainLayer.DTO.Dex.Asset?
    
    init(selectedAsset: DomainLayer.DTO.Dex.Asset?) {
        self.selectedAsset = selectedAsset
    }
    
    override func initialState() -> TradeTypes.State! {
        return TradeTypes.State(uiAction: .none,
                                coreAction: .none,
                                core: .init(pairsPrice: [],
                                            pairsRate: [],
                                            favoritePairs: [],
                                            categories: []),
                                categories: [],
                                selectedFilters: [])
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [categoriesQuery()]
    }
    
    override func reduce(event: TradeTypes.Event, state: inout TradeTypes.State) {
        switch event {
        case .readyView:
            
            state.coreAction = .loadData
            state.uiAction = .updateSkeleton(.init(rows: [.headerCell,
                                                          .defaultCell,
                                                          .defaultCell,
                                                          .defaultCell,
                                                          .defaultCell,
                                                          .defaultCell,
                                                          .defaultCell]))

        case .dataDidLoad(let data):
            state.categories = data.mapCategories(selectedFilters: state.selectedFilters)
            state.coreAction = .none
            state.uiAction = .update
            
        case .didFailGetCategories(let error):
            state.coreAction = .none
            state.uiAction = .didFailGetError(error)
            
        case .refresh:
            state.coreAction = .loadData
            state.uiAction = .none
            
        case .favoriteTapped(let pair):
            let isFavorite = !pair.isFavorite
            
            for index in 0..<state.categories.count {
                
                var category = state.categories[index]
                
                let pairs = category.rows.pairs.map { (element) -> TradeTypes.DTO.Pair in
                    var newPair = element
                    if element.id == pair.id {
                        newPair.isFavorite = isFavorite
                    }
                    return newPair
                }
                
                if category.isFavorite {
                    category.rows = pairs.filter{ $0.isFavorite }.map {.pair($0)}
                }
                else {
                    category.rows = pairs.map {.pair($0)}
                }
                state.categories[index] = category
            }
            state.coreAction = .none
            state.uiAction = .update
    
        case .filterTapped(let filter, atCategory: let categoryIndex):
            
            if let selectedFilter = state.selectedFilters.first(where: {$0.categoryIndex == categoryIndex}) {
                if selectedFilter.filter == filter {
                    state.selectedFilters.removeAll(where: {$0.categoryIndex == categoryIndex})
                }
                else {
                    state.selectedFilters.removeAll(where: {$0.categoryIndex == categoryIndex})
                    state.selectedFilters.append(.init(categoryIndex: categoryIndex,
                                                       filter: filter))

                }
            }
            else {
                state.selectedFilters.append(.init(categoryIndex: categoryIndex,
                                                   filter: filter))
            }
            state.coreAction = .none
            state.uiAction = .none

        }
    
    }
}

private extension TradeSystem {
    
    func categoriesQuery() -> Feedback {
        return react(request: { state -> TradeTypes.State? in
              
            switch state.coreAction {
            case .loadData:
                return state
            default:
                return nil
            }
        }, effects: { [weak self] state -> Signal<TradeTypes.Event> in
 
            guard let self = self else { return Signal.empty() }
            return self.loadData()
                .map { .dataDidLoad($0)}
                .asSignal(onErrorRecover: { error -> Signal<TradeTypes.Event> in

                    if let error = error as? NetworkError {
                        return Signal.just(.didFailGetCategories(error))
                    }
                    return Signal.just(.didFailGetCategories(NetworkError.error(by: error)))
            })
        })
    }
}

private extension TradeSystem {
    
    func loadData() -> Observable<TradeTypes.DTO.Core> {
        
        return auth.authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<TradeTypes.DTO.Core> in
                guard let self = self else { return Observable.empty() }
                
                let tradeCagegories = self.tradeCategoriesRepository.tradeCagegories(accountAddress: wallet.address)
                let favoritePairs = self.dexRealmRepository.list(by: wallet.address)
                
                return Observable.zip(tradeCagegories, favoritePairs)
                    .flatMap { [weak self] (categories, favoritePairs) -> Observable<TradeTypes.DTO.Core> in
                        guard let self = self else { return Observable.empty() }
                        
                        var pairs: [DomainLayer.DTO.Dex.SimplePair] = []
                                                                  
                        for category in categories {
                            for pair in category.pairs {
                                let simplePair = DomainLayer.DTO.Dex.SimplePair(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id)
                                if !pairs.contains(simplePair) {
                                    pairs.append(simplePair)
                                }
                            }
                        }
                        
                        for pair in favoritePairs {
                            let simplePair = DomainLayer.DTO.Dex.SimplePair(amountAsset: pair.amountAssetId, priceAsset: pair.priceAssetId)
                            if !pairs.contains(simplePair) {
                                pairs.append(simplePair)
                            }
                        }
                        
                        let pairsPrice = self.pairsPriceRepository.pairs(accountAddress: wallet.address, pairs: pairs)
                        let pairsRate = self.pairsPriceRepository.pairsRate(query: .init(pairs: pairs.map { .init(amountAsset: $0.amountAsset,
                                                                                                                  priceAsset: Constants.usdAssetId)},
                                                                                         timestamp: nil))
                        
                        return Observable.zip(pairsPrice, pairsRate)
                            .map { (pairsPrice, pairsRate) -> TradeTypes.DTO.Core in
                           
                                return TradeTypes.DTO.Core(pairsPrice: pairsPrice,
                                                           pairsRate: pairsRate,
                                                           favoritePairs: favoritePairs,
                                                           categories: categories)

                        }
                }
        }
    }
}
