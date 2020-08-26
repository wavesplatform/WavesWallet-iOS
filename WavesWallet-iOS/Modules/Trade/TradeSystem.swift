//
//  TradeSystem.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxCocoa
import RxFeedback
import RxSwift
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

    private let developmentConfigsRepository = UseCasesFactory.instance.repositories.developmentConfigsRepository
    private let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
    
    private let selectedAsset: Asset?

    init(selectedAsset: Asset?) {
        self.selectedAsset = selectedAsset
    }

    override func initialState() -> TradeTypes.State! {
        TradeTypes.State(uiAction: .none,
                         coreAction: .none,
                         core: .init(pairsPrice: [],
                                     pairsRate: [],
                                     favoritePairs: [],
                                     categories: [],
                                     lockedPairs: [],
                                     enableCreateSmartContractPairOrder: true),
                         categories: [],
                         selectedFilters: [],
                         selectedAsset: selectedAsset)
    }

    override func internalFeedbacks() -> [Feedback] {
        [loadDataQuery(), removeFromFavoriteQuery(), saveToFavoriteQuery(), favoritePairsQuery()]
    }

    override func reduce(event: TradeTypes.Event, state: inout TradeTypes.State) {
        switch event {
        case .readyView:

            state.coreAction = .loadData(state.selectedAsset)
            state.uiAction = .updateSkeleton(skeletonSection)

        case let .dataDidLoad(data):

            var isEmptyFavorites: Bool {
                if let asset = state.selectedAsset {
                    return data.favoritePairs.assetsIds.contains(asset.id) == false
                }
                return data.favoritePairs.isEmpty
            }

            let initialCurrentIndex: Int = state.core.categories.isEmpty && !data.categories.isEmpty && isEmptyFavorites ? 1 : 0
            state.core = data
            state.categories = data.mapCategories(selectedFilters: state.selectedFilters, selectedAsset: state.selectedAsset)
            state.coreAction = .none
            state.uiAction = .update(initialCurrentIndex: initialCurrentIndex)

        case let .didFailGetCategories(error):
            state.coreAction = .none
            state.uiAction = .didFailGetError(error)

        case .refresh:
            if state.categories.isEmpty {
                state.uiAction = .updateSkeleton(skeletonSection)
            } else {
                state.uiAction = .none
            }
            state.coreAction = .loadData(state.selectedAsset)

        case .refresIfNeed:
            if !state.categories.isEmpty {
                state.coreAction = .loadFavoritePairs
            }

            state.uiAction = .none

        case let .favoritePairsDidLoad(pairs):

            if state.core.favoritePairs != pairs {
                state.coreAction = .loadData(state.selectedAsset)
            } else {
                state.coreAction = .none
            }

            state.uiAction = .none

        case let .favoriteTapped(pair):
            let isFavorite = !pair.isFavorite

            if isFavorite {
                state.coreAction = .saveToToFavorite(pair)
                state.uiAction = .none
            } else {
                let favoriteCategory = state.categories[0]
                if let index = favoriteCategory.rows.firstIndex(where: { $0.pair == pair }) {
                    if favoriteCategory.rows.count == 1 {
                        state.uiAction = .reloadRowAt(IndexPath(row: index, section: 0))
                    } else {
                        state.uiAction = .deleteRowAt(IndexPath(row: index, section: 0))
                    }
                } else {
                    state.uiAction = .update(initialCurrentIndex: nil)
                }

                state.core.favoritePairs.removeAll(where: { $0.id == pair.id })
                state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters,
                                                            selectedAsset: state.selectedAsset)
                state.coreAction = .removeFromFavorite(pair.id)
            }

        case .favoriteDidSuccessRemove:
            state.uiAction = .none
            state.coreAction = .none

        case let .favoriteDidSuccessSave(favoritePairs):
            state.core.favoritePairs = favoritePairs
            state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters,
                                                        selectedAsset: state.selectedAsset)
            state.uiAction = .update(initialCurrentIndex: nil)
            state.coreAction = .none

        case let .filterTapped(filter, categoryIndex):

            if let index = state.selectedFilters.firstIndex(where: { $0.categoryIndex == categoryIndex }) {
                var selectedFilter = state.selectedFilters[index]

                if selectedFilter.filters.contains(filter) {
                    selectedFilter.filters.removeAll(where: { $0 == filter })
                } else {
                    selectedFilter.filters.append(filter)
                }

                state.selectedFilters[index] = selectedFilter
            } else {
                state.selectedFilters.append(.init(categoryIndex: categoryIndex, filters: [filter]))
            }

            state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters,
                                                        selectedAsset: state.selectedAsset)
            state.coreAction = .none
            state.uiAction = .update(initialCurrentIndex: nil)

        case let .deleteFilter(categoryIndex):
            if let index = state.selectedFilters.firstIndex(where: { $0.categoryIndex == categoryIndex }) {
                state.selectedFilters.remove(at: index)
                state.categories = state.core.mapCategories(selectedFilters: state.selectedFilters,
                                                            selectedAsset: state.selectedAsset)
                state.uiAction = .update(initialCurrentIndex: nil)
                state.coreAction = .none
            }
        }
    }

    private var skeletonSection: TradeTypes.ViewModel.SectionSkeleton {
        .init(rows: [.headerCell,
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
        react(request: { state -> TradeTypes.State? in
            switch state.coreAction {
            case .loadFavoritePairs:
                return state
            default:
                return nil
            }
        }, effects: { [weak self] _ -> Signal<TradeTypes.Event> in
            guard let self = self else { return Signal.empty() }
            return self.loadFavoritePairs()
                .map { .favoritePairsDidLoad($0) }
                .asSignal(onErrorSignalWith: Signal.empty())
       })
    }

    func loadDataQuery() -> Feedback {
        react(request: { state -> TradeTypes.State? in
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
                .map { .dataDidLoad($0) }
                .asSignal(onErrorRecover: { error -> Signal<TradeTypes.Event> in
                    if let error = error as? NetworkError {
                        return Signal.just(.didFailGetCategories(error))
                    }

                    return Signal.just(.didFailGetCategories(NetworkError.error(by: error)))
                })
        })
    }

    func removeFromFavoriteQuery() -> Feedback {
        react(request: { state -> TradeTypes.State? in
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
        react(request: { state -> TradeTypes.State? in
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
        auth.authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> in
                guard let self = self else { return Observable.empty() }
                return self.dexRealmRepository.list(by: wallet.address)
            }
    }

    func saveToFavorite(pair: TradeTypes.DTO.Pair) -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> {
        auth.authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> in
                guard let self = self else { return Observable.empty() }
                return self.dexRealmRepository.save(pair: .init(id: pair.id,
                                                                isGeneral: pair.isGeneral,
                                                                amountAsset: pair.amountAsset,
                                                                priceAsset: pair.priceAsset),
                                                    accountAddress: wallet.address)
                    .flatMap { [weak self] _ -> Observable<[DomainLayer.DTO.Dex.FavoritePair]> in
                        guard let self = self else { return Observable.empty() }
                        return self.dexRealmRepository.list(by: wallet.address)
                    }
            }
    }

    func removeFromFavorite(id: String) -> Observable<Bool> {
        auth.authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                return self.dexRealmRepository.delete(by: id, accountAddress: wallet.address)
            }
    }

    func loadData(selectedAsset: Asset?) -> Observable<TradeTypes.DTO.Core> {
        
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()
        let wallet = auth.authorizedWallet()
        
        return Observable.zip(serverEnvironment, wallet)
            .flatMap { [weak self] serverEnvironment, wallet -> Observable<TradeTypes.DTO.Core> in
                guard let self = self else { return Observable.empty() }

                let tradeCagegories = self
                    .tradeCategoriesRepository
                    .tradeCagegories(serverEnvironment: serverEnvironment,
                                     accountAddress: wallet.address)
                
                let favoritePairs = self.dexRealmRepository.list(by: wallet.address)

                return Observable.zip(tradeCagegories, favoritePairs)
                    .flatMap { [weak self] categories, favoritePairs
                        -> Observable<(pairs: [DomainLayer.DTO.CorrectionPairs.Pair],
                                       categories: [TradeTypes.DTO.Category],
                                       favoritePairs: [DomainLayer.DTO.Dex.FavoritePair])> in
                        guard let self = self else { return Observable.empty() }

                        let dataCategories = categories.map { category -> TradeTypes.DTO.Category in

                            let filters = category.filters.map { TradeTypes.DTO.Category.Filter(name: $0.name, ids: $0.ids) }

                            var pairs = category.pairs

                            if let asset = selectedAsset {
                                pairs = pairs.filterByAsset(asset.id)

                                if pairs.isEmpty {
                                    pairs = category.matchingAssets.map {
                                        DomainLayer.DTO.Dex.Pair(amountAsset: asset, priceAsset: $0)
                                    }
                                }
                            }

                            return TradeTypes.DTO.Category(name: category.name, filters: filters, pairs: pairs)
                        }

                        var pairsSet: [DomainLayer.DTO.CorrectionPairs.Pair] = []

                        let simpleFavoritePairs = favoritePairs.map {
                            DomainLayer.DTO.CorrectionPairs.Pair(amountAsset: $0.amountAssetId,
                                                                 priceAsset: $0.priceAssetId)
                        }

                        let simplePairs = dataCategories.map {
                            $0.pairs.map { DomainLayer.DTO.CorrectionPairs.Pair(amountAsset: $0.amountAsset.id,
                                                                                priceAsset: $0.priceAsset.id)
                            }
                        }
                        .flatMap { $0 }

                        pairsSet.append(contentsOf: simpleFavoritePairs)
                        pairsSet.append(contentsOf: simplePairs)

                        return self
                            .correctionPairsUseCase
                            .correction(pairs: Array(pairsSet))
                            .map { (pairs: $0,
                                    categories: dataCategories,
                                    favoritePairs: favoritePairs)
                            }
                    }
                    .flatMap { [weak self] pairs, categories, favoritePairs -> Observable<TradeTypes.DTO.Core> in

                        guard let self = self else { return Observable.empty() }

                        let simplePairs = pairs.map {
                            DomainLayer.DTO.Dex.SimplePair(amountAsset: $0.amountAsset, priceAsset: $0.priceAsset)
                        }
                        
                                            
                        let pairsPrice = self
                            .serverEnvironmentUseCase
                            .serverEnvironment()
                            .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Dex.PairPrice]> in
                                
                                guard let self = self else { return Observable.empty() }
                                
                                return self
                                    .pairsPriceRepository
                                    .pairs(serverEnvironment: serverEnvironment,
                                           accountAddress: wallet.address,
                                           pairs: simplePairs)
                            }
                        

                        let queryPairs: [DomainLayer.DTO.Dex.SimplePair] = pairs.map {
                            .init(amountAsset: $0.amountAsset, priceAsset: Constants.usdAssetId)
                        }
                        let query = DomainLayer.Query.Dex.PairsRate(pairs: queryPairs, timestamp: nil)
                                                
                        let pairsRate = self
                            .serverEnvironmentUseCase
                            .serverEnvironment()
                            .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Dex.PairRate]> in
                                
                                guard let self = self else { return Observable.empty() }
                                
                                return self.pairsPriceRepository
                                    .pairsRate(serverEnvironment: serverEnvironment,
                                               query: query)
                            }
                        

                        let mapPairs = pairs
                            .reduce(into: [String: DomainLayer.DTO.CorrectionPairs.Pair]()) { $0[$1.keyPair] = $1 }

                        let tradeCategories = categories.map { category -> TradeTypes.DTO.Category in

                            let pairs = category.pairs.map { pair -> DomainLayer.DTO.Dex.Pair? in

                                if mapPairs[pair.keyPair] != nil {
                                    return DomainLayer.DTO.Dex.Pair(amountAsset: pair.amountAsset,
                                                                    priceAsset: pair.priceAsset)
                                } else if mapPairs[pair.inversionKeyPair] != nil {
                                    return DomainLayer.DTO.Dex.Pair(amountAsset: pair.priceAsset,
                                                                    priceAsset: pair.amountAsset)
                                }
                                return nil
                            }
                            .compactMap { $0 }

                            return .init(name: category.name, filters: category.filters, pairs: pairs)
                        }
                        
                        let developmentConfigs = self
                            .developmentConfigsRepository
                            .developmentConfigs()
                        
                        return Observable.zip(pairsPrice,
                                              pairsRate,
                                              developmentConfigs)
                            .map { pairsPrice, pairsRate, developmentConfigs -> TradeTypes.DTO.Core in
                                                          
                                let lockedPairs = developmentConfigs.lockedPairs
                                let enableCreateSmartContractPairOrder = developmentConfigs.enableCreateSmartContractPairOrder
                                return .init(pairsPrice: pairsPrice,
                                             pairsRate: pairsRate,
                                             favoritePairs: favoritePairs,
                                             categories: tradeCategories,
                                             lockedPairs: lockedPairs,
                                             enableCreateSmartContractPairOrder: enableCreateSmartContractPairOrder)
                            }
                }
                .catchError { (error) -> Observable<TradeTypes.DTO.Core> in
                    return Observable.error(error)
                }
            }
    }
}

private extension Array where Element == DomainLayer.DTO.CorrectionPairs.Pair {
    func hasAsset(_ assetId: String) -> Bool {
        !filterByAsset(assetId).isEmpty
    }

    func filterByAsset(_ assetId: String) -> [DomainLayer.DTO.CorrectionPairs.Pair] {
        filter { $0.amountAsset == assetId || $0.priceAsset == assetId }
    }
}

private extension Array where Element == DomainLayer.DTO.Dex.Pair {
    func hasAsset(_ assetId: String) -> Bool {
        !filterByAsset(assetId).isEmpty
    }

    func filterByAsset(_ assetId: String) -> [DomainLayer.DTO.Dex.Pair] {
        filter { $0.amountAsset.id == assetId || $0.priceAsset.id == assetId }
    }
}

private extension DomainLayer.DTO.CorrectionPairs.Pair {
    var keyPair: String { "\(amountAsset)/\(priceAsset)" }
}

private extension DomainLayer.DTO.Dex.Pair {
    var keyPair: String { "\(amountAsset.id)/\(priceAsset.id)" }

    var inversionKeyPair: String { "\(priceAsset.id)/\(amountAsset.id)" }
}
