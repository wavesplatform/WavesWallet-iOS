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

final class TradeSystem: System<TradeTypes.State, TradeTypes.Event> {
    
    private let tradeCategoriesRepository = UseCasesFactory.instance.repositories.tradeCategoriesConfigRepository
    private let dexRealmRepository = UseCasesFactory.instance.repositories.dexRealmRepository
    private let dexListRepository = UseCasesFactory.instance.repositories.dexPairsPriceRepository
    private let auth: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    
    override func initialState() -> TradeTypes.State! {
        return TradeTypes.State(uiAction: .none,
                                coreAction: .none,
                                categories: [])
    }
    
    override func internalFeedbacks() -> [Feedback] {
        return [categoriesQuery()]
    }
    
    override func reduce(event: TradeTypes.Event, state: inout TradeTypes.State) {
        switch event {
        case .readyView:
            state.coreAction = .loadCategories
            state.uiAction = .none

        case .categoriesDidLoad(let categories):
            state.categories = categories
            state.coreAction = .none
            state.uiAction = .update
            
        case .didFailGetCategories(let error):
            state.coreAction = .none
            state.uiAction = .didFailGetError(error)
            
        case .refresh:
            state.coreAction = .loadCategories
            state.uiAction = .none
        }
    }
}

private extension TradeSystem {
    
    func categoriesQuery() -> Feedback {
        return react(request: { state -> TradeTypes.State? in
              
            switch state.coreAction {
            case .loadCategories:
                return state
            default:
                return nil
            }
        }, effects: { [weak self] state -> Signal<TradeTypes.Event> in

            guard let self = self else { return Signal.empty() }
            return self.loadCategories()
                .map { .categoriesDidLoad($0)}
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
    
    func loadCategories() -> Observable<[TradeTypes.DTO.Category]> {
        
        return auth.authorizedWallet()
            .flatMap { [weak self] (wallet) -> Observable<[TradeTypes.DTO.Category]> in
                guard let self = self else { return Observable.empty() }
                return self.tradeCategoriesRepository.tradeCagegories(accountAddress: wallet.address)
                    .flatMap { [weak self] (categories) -> Observable<[TradeTypes.DTO.Category]> in
                        
                        guard let self = self else { return Observable.empty() }
                        
                        var pairs: [DomainLayer.DTO.Dex.Pair] = []
                                           
                        for category in categories {
                            for pair in category.pairs {
                                if !pairs.contains(pair) {
                                    pairs.append(pair)
                                }
                            }
                        }
                        
                        return self.dexListRepository.list(accountAddress: wallet.address,
                                                           pairs: pairs.map {DomainLayer.DTO.Dex.SimplePair(amountAsset: $0.amountAsset.id,
                                                                                                            priceAsset: $0.priceAsset.id)})
                            .map { (pairsPrice) -> [TradeTypes.DTO.Category] in
                                
                                var newCategories: [TradeTypes.DTO.Category] = []
                                newCategories.append(.init(isFavorite: true,
                                                           name: "",
                                                           filters: [],
                                                           pairs: []))
                                
                                
                                newCategories.append(contentsOf: categories.map { .init(isFavorite: false,
                                                                                      name: $0.name,
                                                                                      filters: $0.filters,
                                                                                      pairs: [])})
                                return newCategories
                        }
                }
        }
    }
}
