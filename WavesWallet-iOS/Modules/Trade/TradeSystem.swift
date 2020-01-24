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
        return [loadDataQuery(), removeFromFavoriteQuery(), saveToFavoriteQuery()]
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
            state.core = data
            state.categories = data.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: selectedAsset)
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
            
            if isFavorite {
                state.coreAction = .saveToToFavorite(pair)
                state.uiAction = .none
            }
            else {
                state.core.favoritePairs.removeAll(where: {$0.id == pair.id})
                state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: selectedAsset)
                state.coreAction = .removeFromFavorite(pair.id)
                state.uiAction = .update
            }
            
        case .favoriteDidSuccessRemove:
            state.uiAction = .none
            state.coreAction = .none
            
        case .favoriteDidSuccessSave(let favoritePairs):
            state.core.favoritePairs = favoritePairs
            state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: selectedAsset)
            state.uiAction = .update
            state.coreAction = .none
            
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
            
            state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: selectedAsset)
            state.coreAction = .none
            state.uiAction = .update

        }
    
    }
}

//MARK: - Feedback Query
private extension TradeSystem {
    
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
