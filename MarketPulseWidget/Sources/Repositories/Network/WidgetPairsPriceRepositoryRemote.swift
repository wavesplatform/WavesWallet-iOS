//
//  WidgetPairsPriceRepositoryRemote.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import Extensions

protocol WidgetPairsPriceRepositoryProtocol {
    
    func searchPairs(_ query: DomainLayer.Query.Dex.SearchPairs) -> Observable<DomainLayer.DTO.Dex.PairsSearch>
}

final class WidgetPairsPriceRepositoryRemote: WidgetPairsPriceRepositoryProtocol {

    private let pairsPriceDataService = WidgetPairsPriceDataService()
    
    private let matcherRepository: MatcherRepositoryProtocol = MatcherRepositoryLocal(matcherRepositoryRemote: WidgetMatcherRepositoryRemote())
    
    func searchPairs(_ query: DomainLayer.Query.Dex.SearchPairs) -> Observable<DomainLayer.DTO.Dex.PairsSearch> {
        
        //TODO: Others type kinds
        guard case let .pairs(pairs) = query.kind else { return Observable.never() }
        
        
        let pairsForQuery = pairs.map { WidgetDataService.Query.PairsPrice.Pair(amountAssetId: $0.amountAsset,
                                                                          priceAssetId: $0.priceAsset) }
                        
        return matcherRepository
            .matcherPublicKey()
            .flatMap { [weak self] (publicKey) -> Observable<DomainLayer.DTO.Dex.PairsSearch> in
                
                guard let self = self else { return Observable.never() }
                
                let query = WidgetDataService.Query.PairsPrice(pairs: pairsForQuery, matcher: publicKey.address)
                    
                return self.pairsPriceDataService
                        .pairsPrice(query: query)
                        .map({ (pairsSearch) -> DomainLayer.DTO.Dex.PairsSearch in
                        
                            let pairs = pairsSearch.map({ (pairPrice) -> DomainLayer
                                .DTO
                                .Dex
                                .PairsSearch
                                .Pair? in
                                
                                guard let pairPrice = pairPrice else { return nil }
                                
                                return DomainLayer
                                    .DTO
                                    .Dex
                                    .PairsSearch
                                    .Pair.init(firstPrice: pairPrice.firstPrice,
                                               lastPrice: pairPrice.lastPrice,
                                               volume: pairPrice.volume,
                                               volumeWaves: pairPrice.volumeWaves,
                                               quoteVolume: pairPrice.quoteVolume)
                            })
                            
                            
                            
                            return DomainLayer.DTO.Dex.PairsSearch(pairs: pairs)
                    })
            }
    }
}
