//
//  WidgetPairsPriceRepositoryRemote.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift

extension MarketPulse.DTO {
    struct Rate {
        let amountAssetId: String
        let priceAssetId: String
        let rate: Double
    }
}

extension MarketPulse.Query {
    struct Rates {
        struct Pair {
            let amountAssetId: String
            let priceAssetId: String
        }
        
        let pair: [Pair]
        let timestamp: Date?
    }
}

protocol WidgetPairsPriceRepositoryProtocol {
    func searchPairs(_ query: DomainLayer.Query.Dex.SearchPairs) -> Observable<DomainLayer.DTO.Dex.PairsSearch>
    
    func ratePairs(_ query: MarketPulse.Query.Rates) -> Observable<[MarketPulse.DTO.Rate]>
}

final class WidgetPairsPriceRepositoryRemote {
    private let pairsPriceDataService: WidgetPairsPriceDataServiceProtocol = WidgetPairsPriceDataService()
    
    private let matcherRepository = WidgetMatcherRepositoryRemote()
    
    func ratePairs(_ query: MarketPulse.Query.Rates) -> Observable<[MarketPulse.DTO.Rate]> {
        return matcherRepository
            .matcherPublicKey()
            .flatMap { [weak self] publicKey -> Observable<[MarketPulse.DTO.Rate]> in
                guard let self = self else { return Observable.never() }
                
                let pair = query.pair.map {
                    WidgetDataService.Query.Rates.Pair(amountAssetId: $0.amountAssetId, priceAssetId: $0.priceAssetId)
                }
                let query = WidgetDataService.Query.Rates(pair: pair, matcher: publicKey.address, timestamp: query.timestamp)
                return self.pairsPriceDataService
                    .pairsRate(query: query)
                    .map {
                        $0.map {
                            MarketPulse.DTO.Rate(amountAssetId: $0.amountAssetId, priceAssetId: $0.priceAssetId, rate: $0.rate)
                        }
                    }
            }
    }
    
    func searchPairs(_ query: DomainLayer.Query.Dex.SearchPairs) -> Observable<DomainLayer.DTO.Dex.PairsSearch> {
        // TODO: Others type kinds
        guard case let .pairs(pairs) = query.kind else { return Observable.never() }
        
        let pairsForQuery = pairs.map {
            WidgetDataService.Query.PairsPrice.Pair(amountAssetId: $0.amountAsset, priceAssetId: $0.priceAsset)
        }
        
        return matcherRepository
            .matcherPublicKey()
            .flatMap { [weak self] publicKey -> Observable<DomainLayer.DTO.Dex.PairsSearch> in
                guard let self = self else { return Observable.never() }
                
                let query = WidgetDataService.Query.PairsPrice(pairs: pairsForQuery, matcher: publicKey.address)
                
                return self.pairsPriceDataService
                    .pairsPrice(query: query)
                    .map { pairsSearch -> DomainLayer.DTO.Dex.PairsSearch in
                        let pairs = pairsSearch.map { pairPrice -> DomainLayer.DTO.Dex.PairsSearch.Pair? in
                            guard let pairPrice = pairPrice else { return nil }
                            
                            return DomainLayer.DTO.Dex.PairsSearch.Pair(firstPrice: pairPrice.firstPrice,
                                                                        lastPrice: pairPrice.lastPrice,
                                                                        volume: pairPrice.volume,
                                                                        volumeWaves: pairPrice.volumeWaves,
                                                                        quoteVolume: pairPrice.quoteVolume)
                        }
                        
                        return DomainLayer.DTO.Dex.PairsSearch(pairs: pairs)
                    }
            }
    }
}
