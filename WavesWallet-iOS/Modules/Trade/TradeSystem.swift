//
//  TradeSystem.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
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
    private let correctionPairsUseCase = UseCasesFactory.instance.correctionPairsUseCase
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
                                selectedFilters: [],
                                selectedAsset: self.selectedAsset)
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [loadDataQuery(), removeFromFavoriteQuery(), saveToFavoriteQuery(), favoritePairsQuery()]
    }
    
    override func reduce(event: TradeTypes.Event, state: inout TradeTypes.State) {
        switch event {
        case .readyView:
            
            state.coreAction = .loadData(state.selectedAsset)
            state.uiAction = .updateSkeleton(skeletonSection)

        case .dataDidLoad(let data):
            
            var isEmptyFavorites: Bool {
                if let asset = state.selectedAsset {
                    return data.favoritePairs.assetsIds.contains(asset.id) == false
                }
                return data.favoritePairs.count == 0
            }
            
            let initialCurrentIndex: Int = state.core.categories.count == 0 && data.categories.count > 0 && isEmptyFavorites ? 1 : 0
            state.core = data
            state.categories = data.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: state.selectedAsset)
            state.coreAction = .none
            state.uiAction = .update(initialCurrentIndex: initialCurrentIndex)
            
        case .didFailGetCategories(let error):
            state.coreAction = .none
            state.uiAction = .didFailGetError(error)
            
        case .refresh:
            if state.categories.count == 0 {
                state.uiAction = .updateSkeleton(skeletonSection)
            }
            else {
                state.uiAction = .none
            }
            state.coreAction = .loadData(state.selectedAsset)
            
        case .refresIfNeed:
            if state.categories.count > 0 {
                state.coreAction = .loadFavoritePairs
            }
           
            state.uiAction = .none
            
        case .favoritePairsDidLoad(let pairs):
            
            if state.core.favoritePairs != pairs {
                state.coreAction = .loadData(state.selectedAsset)
            }
            else {
                state.coreAction = .none
            }
            
            state.uiAction = .none
            
        case .favoriteTapped(let pair):
            let isFavorite = !pair.isFavorite
            
            if isFavorite {
                state.coreAction = .saveToToFavorite(pair)
                state.uiAction = .none
            }
            else {
                
                let favoriteCategory = state.categories[0]
                if let index = favoriteCategory.rows.firstIndex(where: {$0.pair == pair}) {
                    if favoriteCategory.rows.count == 1 {
                        state.uiAction = .reloadRowAt(IndexPath(row: index, section: 0))
                    }
                    else {
                        state.uiAction = .deleteRowAt(IndexPath(row: index, section: 0))
                    }
                }
                else {
                    state.uiAction = .update(initialCurrentIndex: nil)
                }
                
                state.core.favoritePairs.removeAll(where: {$0.id == pair.id})
                state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: state.selectedAsset)
                state.coreAction = .removeFromFavorite(pair.id)
            }
            
        case .favoriteDidSuccessRemove:
            state.uiAction = .none
            state.coreAction = .none
            
        case .favoriteDidSuccessSave(let favoritePairs):
            state.core.favoritePairs = favoritePairs
            state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: state.selectedAsset)
            state.uiAction = .update(initialCurrentIndex: nil)
            state.coreAction = .none
            
        case .filterTapped(let filter, atCategory: let categoryIndex):
            
            if let index = state.selectedFilters.firstIndex(where: {$0.categoryIndex == categoryIndex}) {
                var selectedFilter = state.selectedFilters[index]
                
                if selectedFilter.filters.contains(filter) {
                    selectedFilter.filters.removeAll(where: {$0 == filter})
                }
                else {
                    selectedFilter.filters.append(filter)
                }
                
                state.selectedFilters[index] = selectedFilter
            }
            else {
                state.selectedFilters.append(.init(categoryIndex: categoryIndex, filters: [filter]))
            }
            
            state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: state.selectedAsset)
            state.coreAction = .none
            state.uiAction = .update(initialCurrentIndex: nil)
        
        case .deleteFilter(let categoryIndex):
            if let index = state.selectedFilters.firstIndex(where: {$0.categoryIndex == categoryIndex}) {
                state.selectedFilters.remove(at: index)
                state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: state.selectedAsset)
                state.uiAction = .update(initialCurrentIndex: nil)
                state.coreAction = .none
            }
        }
        
    }
    
    private var skeletonSection: TradeTypes.ViewModel.SectionSkeleton {
        return .init(rows: [.headerCell,
                            .defaultCell,
                            .defaultCell,
                            .defaultCell,
                            .defaultCell,
                            .defaultCell,
                            .defaultCell])
    }
}

// MARK: - Feedback Query
private extension TradeSystem {
    
    func favoritePairsQuery() -> Feedback {
        return react(request: { state -> TradeTypes.State? in
                     
           switch state.coreAction {
           case .loadFavoritePairs:
               return state
           default:
               return nil
           }
       }, effects: { [weak self] state -> Signal<TradeTypes.Event> in

           guard let self = self else { return Signal.empty() }
           return self.loadFavoritePairs()
            .map { .favoritePairsDidLoad($0) }
            .asSignal(onErrorSignalWith: Signal.empty())

       })
    }
    
    func loadDataQuery() -> Feedback {
        return react(request: { state -> TradeTypes.State? in
              
            switch state.coreAction {
            case .loadData:
                return state
            default:
                return nil
            }
        }, effects: { [weak self] state -> Signal<TradeTypes.Event> in
 
            guard let self = self else { return Signal.empty() }
            return self
                .loadData(selectedAsset: state.selectedAsset)
                .map { .dataDidLoad($0)}
                .asSignal(onErrorRecover: { error -> Signal<TradeTypes.Event> in

                    if let error = error as? NetworkError {
                        return Signal.just(.didFailGetCategories(error))
                    }
                    return Signal.just(.didFailGetCategories(NetworkError.error(by: error)))
            })
        })
    }
    
    func removeFromFavoriteQuery() -> Feedback {
        
         return react(request: { state -> TradeTypes.State? in
            
            switch state.coreAction {
            case .removeFromFavorite:
                return state
            default:
                return nil
            }
        }, effects: { [weak self] state -> Signal<TradeTypes.Event> in
        
            guard let self = self else { return Signal.empty() }
            if case let .removeFromFavorite(id) = state.coreAction {
                    
                return self.removeFromFavorite(id: id)
                    .map { _ in .favoriteDidSuccessRemove }
                    .asSignal(onErrorSignalWith: Signal.empty())
            }
            return Signal.empty()
        })
    }
    
    func saveToFavoriteQuery() -> Feedback {
        return react(request: { state -> TradeTypes.State? in
                  
              switch state.coreAction {
              case .saveToToFavorite:
                  return state
              default:
                  return nil
              }
          }, effects: { [weak self] state -> Signal<TradeTypes.Event> in
          
              guard let self = self else { return Signal.empty() }
              if case let .saveToToFavorite(pair) = state.coreAction {
                      
                  return self.saveToFavorite(pair: pair)
                      .map { .favoriteDidSuccessSave($0) }
                      .asSignal(onErrorSignalWith: Signal.empty())
              }
              return Signal.empty()
          })
    }
}


private extension TradeSystem {
    
    func loadFavoritePairs() -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> {
        return auth.authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> in
                guard let self = self else { return Observable.empty() }
                return self.dexRealmRepository.list(by: wallet.address)
        }
    }
    
    func saveToFavorite(pair: TradeTypes.DTO.Pair) -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> {
        return auth.authorizedWallet()
            .flatMap {[weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.FavoritePair]>  in
                guard let self = self else { return Observable.empty()}
                return self.dexRealmRepository.save(pair: .init(id: pair.id,
                                                                isGeneral: pair.isGeneral,
                                                                amountAsset: pair.amountAsset,
                                                                priceAsset: pair.priceAsset),
                                                    accountAddress: wallet.address)
                    .flatMap {[weak self] (success) -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> in
                        guard let self = self else { return Observable.empty() }
                        return self.dexRealmRepository.list(by: wallet.address)
                    }
        }
    }
    
    
    func removeFromFavorite(id: String) -> Observable<Bool> {
        return auth.authorizedWallet()
            .flatMap {[weak self] (wallet) -> Observable<Bool> in
                guard let self = self else { return Observable.empty()}
                return self.dexRealmRepository.delete(by: id, accountAddress: wallet.address)
        }
    }
            
    func loadData(selectedAsset: DomainLayer.DTO.Dex.Asset?) -> Observable<TradeTypes.DTO.Core> {
        
        return auth.authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<TradeTypes.DTO.Core> in
                guard let self = self else { return Observable.empty() }
                
                let tradeCagegories = self.tradeCategoriesRepository.tradeCagegories(accountAddress: wallet.address)
                let favoritePairs = self.dexRealmRepository.list(by: wallet.address)
                
                                                
                return Observable.zip(tradeCagegories, favoritePairs)
                    .flatMap { [weak self] (categories, favoritePairs) -> Observable<(pairs: [DomainLayer.DTO.CorrectionPairs.Pair],
                                                                                      categories: [TradeTypes.DTO.Category],
                                                                                      favoritePairs: [DomainLayer.DTO.Dex.FavoritePair])> in
                
                        guard let self = self else { return Observable.empty() }
                                                                        
                        let dataCategories = categories.map { category -> TradeTypes.DTO.Category in
                                  
                            let filters: [TradeTypes.DTO.Category.Filter] = category.filters.map { .init(name: $0.name, ids: $0.ids) }
                            
                            var pairs = category.pairs
                                                        
                            if let asset = selectedAsset {
                                pairs = pairs.filterByAsset(asset.id)

                                if pairs.count == 0 {
                                    pairs = category.matchingAssets.map { DomainLayer.DTO.Dex.Pair.init(amountAsset: asset,
                                                                                                        priceAsset: $0) }
                                }
                            }

                            return TradeTypes.DTO.Category.init(name: category.name,
                                                                filters: filters,
                                                                pairs: pairs)
                        }
                                                                                                   
                        var pairsSet: [DomainLayer.DTO.CorrectionPairs.Pair] = []

                        let simpleFavoritePairs  = favoritePairs.map { DomainLayer.DTO.CorrectionPairs.Pair(amountAsset: $0.amountAssetId,
                                                                                                            priceAsset: $0.priceAssetId) }

                        let simplePairs  = dataCategories.map { $0.pairs.map { DomainLayer.DTO.CorrectionPairs.Pair(amountAsset: $0.amountAsset.id,
                                                                                                                    priceAsset: $0.priceAsset.id) } }
                            .flatMap { $0}

                        pairsSet.append(contentsOf: simpleFavoritePairs)
                        pairsSet.append(contentsOf: simplePairs)

                        return self
                            .correctionPairsUseCase
                            .correction(pairs: Array(pairsSet))
                            .map { (pairs: $0,
                                    categories: dataCategories,
                                    favoritePairs: favoritePairs) }
                }
                .flatMap { [weak self] (pairs, categories, favoritePairs) -> Observable<TradeTypes.DTO.Core> in
                    
                    guard let self = self else { return Observable.empty() }
        
                    let pairsPrice = self.pairsPriceRepository.pairs(accountAddress: wallet.address,
                                                                     pairs: pairs.map { DomainLayer.DTO.Dex.SimplePair.init(amountAsset: $0.amountAsset,
                                                                                                                            priceAsset: $0.priceAsset) })
                    let pairsRate = self.pairsPriceRepository.pairsRate(query: .init(pairs: pairs.map { .init(amountAsset: $0.amountAsset,
                                                                                                              priceAsset: Constants.usdAssetId)},
                                                                                     timestamp: nil))
                    
                    let mapPairs = pairs.reduce(into: [String: DomainLayer.DTO.CorrectionPairs.Pair].init(), { $0[$1.keyPair] = $1 } )
                    
                    let tradeCategories = categories.map { (category) -> TradeTypes.DTO.Category in
                                                                       
                        let pairs = category.pairs.map { (pair) -> DomainLayer.DTO.Dex.Pair? in
                                
                            if mapPairs[pair.keyPair] != nil {
                                return DomainLayer.DTO.Dex.Pair.init(amountAsset: pair.amountAsset, priceAsset: pair.priceAsset)
                            } else if mapPairs[pair.inversionKeyPair] != nil {
                                return DomainLayer.DTO.Dex.Pair.init(amountAsset: pair.priceAsset, priceAsset: pair.amountAsset)
                            }
                            return nil
                        }
                        .compactMap { $0 }
                        
                        return TradeTypes.DTO.Category.init(name: category.name,
                                                            filters: category.filters,
                                                            pairs: pairs)
                    }
                    
                    return Observable.zip(pairsPrice, pairsRate)
                        .map { (arg) -> TradeTypes.DTO.Core in
                                                        
                            let (pairsPrice, pairsRate) = arg
                            return TradeTypes.DTO.Core(pairsPrice: pairsPrice,
                                                       pairsRate: pairsRate,
                                                       favoritePairs: favoritePairs,
                                                       categories: tradeCategories)

                    }
                }
        }
    }
}

private extension Array where Element == DomainLayer.DTO.CorrectionPairs.Pair {
    
    func hasAsset(_ assetId: String) -> Bool {
        return filterByAsset(assetId).count > 0
    }
    
    func filterByAsset(_ assetId: String) -> [DomainLayer.DTO.CorrectionPairs.Pair] {
        return self.filter { $0.amountAsset == assetId || $0.priceAsset == assetId }
    }
}

private extension Array where Element == DomainLayer.DTO.Dex.Pair {
    
    func hasAsset(_ assetId: String) -> Bool {
        return filterByAsset(assetId).count > 0
    }
    
    func filterByAsset(_ assetId: String) -> [DomainLayer.DTO.Dex.Pair] {
        return self.filter { $0.amountAsset.id == assetId || $0.priceAsset.id == assetId }
    }
}

private extension DomainLayer.DTO.CorrectionPairs.Pair {
    
    var keyPair: String {
        return "\(amountAsset)/\(priceAsset)"
    }
}

private extension DomainLayer.DTO.Dex.Pair {

    var keyPair: String {
        return "\(amountAsset.id)/\(priceAsset.id)"
    }
    
    var inversionKeyPair: String {
        return "\(priceAsset.id)/\(amountAsset.id)"
    }
}

