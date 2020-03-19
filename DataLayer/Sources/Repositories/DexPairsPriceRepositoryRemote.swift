//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer
import Extensions

final class DexPairsPriceRepositoryRemote: DexPairsPriceRepositoryProtocol {
      
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    private let matcherRepository: MatcherRepositoryProtocol
    private let assetsRepository: AssetsRepositoryProtocol
    
    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols,
         matcherRepository: MatcherRepositoryProtocol,
         assetsRepository: AssetsRepositoryProtocol) {
        
        self.environmentRepository = environmentRepository
        self.matcherRepository = matcherRepository
        self.assetsRepository = assetsRepository
    }
    
    func search(by accountAddress: String, searchText: String) -> Observable<[DomainLayer.DTO.Dex.SimplePair]> {
        
        var kind: DataService.Query.PairsPriceSearch.Kind!

        var searchCompoments = searchText.components(separatedBy: "/")
        if searchCompoments.count == 1 {
            searchCompoments = searchText.components(separatedBy: "\\")
        }
        
        if searchCompoments.count == 1 {
            let searchWords = searchCompoments[0].components(separatedBy: " ").filter {$0.count > 0}
            if searchWords.count > 0 {
                kind = .byAsset(searchWords[0])
            }
            else {
                return Observable.just([])
            }
        }
        else if searchCompoments.count >= 2 {
            let searchAmountWords = searchCompoments[0].components(separatedBy: " ").filter {$0.count > 0}
            let searchPriceWords = searchCompoments[1].components(separatedBy: " ").filter {$0.count > 0}
            
            if searchAmountWords.count > 0 && searchPriceWords.count > 0 {
                kind = .byAssets(firstName: searchAmountWords[0], secondName: searchPriceWords[0])
            }
            else if searchAmountWords.count > 0 {
                kind = .byAsset(searchAmountWords[0])
            }
            else if searchPriceWords.count > 0 {
                kind = .byAsset(searchPriceWords[0])
            }
            else {
                return Observable.just([])
            }
        }

        
        return Observable.zip(environmentRepository.servicesEnvironment(),
                              matcherRepository.matcherPublicKey())
            .flatMap({ (servicesEnvironment, matcherPublicKey) -> Observable<[DomainLayer.DTO.Dex.SimplePair]> in
                return servicesEnvironment
                .wavesServices
                .dataServices
                .pairsPriceDataService
                    .searchByAsset(query: .init(kind: kind, matcher: matcherPublicKey.address))
                    .map({ (pairs) -> [DomainLayer.DTO.Dex.SimplePair] in
                        
                        var simplePairs: [DomainLayer.DTO.Dex.SimplePair] = []
                        for pair in pairs {
                            if !simplePairs.contains(where: {$0.amountAsset == pair.amountAsset && $0.priceAsset == pair.priceAsset}) {
                                simplePairs.append(.init(amountAsset: pair.amountAsset, priceAsset: pair.priceAsset))
                            }
                        }
                        return simplePairs
                    })
            })
    }
    
    // TODO: Any model from dataservice return like null. Need refactor
    func pairs(accountAddress: String, pairs: [DomainLayer.DTO.Dex.SimplePair]) -> Observable<[DomainLayer.DTO.Dex.PairPrice]> {

        guard pairs.count > 0 else { return Observable.just([]) }
        
        return Observable.zip(environmentRepository.servicesEnvironment(),
                              matcherRepository.matcherPublicKey(),
                              assetsRepository.assets(by: pairs.assetsIds, accountAddress: accountAddress))
            .flatMapLatest({ (servicesEnvironment, matcherPublicKey, assets) -> Observable<[DomainLayer.DTO.Dex.PairPrice]> in
                
                let pairsForQuery = pairs.map { DataService.Query.PairsPrice.Pair(amountAssetId: $0.amountAsset,
                                                                                  priceAssetId: $0.priceAsset) }
                
                let query = DataService.Query.PairsPrice(pairs: pairsForQuery, matcher: matcherPublicKey.address)
                
                return servicesEnvironment
                    .wavesServices
                    .dataServices
                    .pairsPriceDataService
                    .pairsPrice(query: query)
                    .map({ (list) -> [DomainLayer.DTO.Dex.PairPrice] in
                        
                        var listPairs: [DomainLayer.DTO.Dex.PairPrice] = []
    
                        for (index, pairElement) in list.enumerated() {
                            
                            let localPair = pairs[index]
                            
                            guard let priceAsset = assets.first(where: {$0.id == localPair.priceAsset}) else { continue }
                            guard let amountAsset = assets.first(where: {$0.id == localPair.amountAsset}) else { continue }
                            
                            let firstPrice = Money(value: Decimal(pairElement?.firstPrice ?? 0), priceAsset.precision)
                            let lastPrice = Money(value: Decimal(pairElement?.lastPrice ?? 0), priceAsset.precision)
                            
                            let pairPrice = DomainLayer.DTO.Dex.PairPrice(firstPrice: firstPrice,
                                                                          lastPrice: lastPrice,
                                                                          amountAsset: amountAsset.dexAsset,
                                                                          priceAsset: priceAsset.dexAsset,
                                                                          isGeneral: priceAsset.isGeneral && amountAsset.isGeneral,
                                                                          volumeWaves: pairElement?.volumeWaves ?? 0)
                            listPairs.append(pairPrice)
                        }
                        
                        return listPairs
                    })
            })
    }
    
    func pairsRate(query: DomainLayer.Query.Dex.PairsRate) -> Observable<[DomainLayer.DTO.Dex.PairRate]> {

        return Observable.zip(environmentRepository.servicesEnvironment(),
                              matcherRepository.matcherPublicKey())
            .flatMap { (servicesEnvironment, matcherPublicKey) -> Observable<[DomainLayer.DTO.Dex.PairRate]> in
                
                let queryPairs = query.pairs.map { DataService.Query.PairsRate.Pair(amountAssetId: $0.amountAsset,
                                                                                    priceAssetId: $0.priceAsset)}
                return servicesEnvironment
                    .wavesServices
                    .dataServices
                    .pairsPriceDataService
                    .pairsRate(query: .init(pairs: queryPairs,
                                            matcher: matcherPublicKey.address,
                                            timestamp: query.timestamp?.millisecondsSince1970))
                    .map { $0.map { DomainLayer.DTO.Dex.PairRate(amountAssetId: $0.amountAssetId,
                                                                 priceAssetId: $0.priceAssetId,
                                                                 rate: $0.rate)}}
            }
       
    }
    
    func searchPairs(_ query: DomainLayer.Query.Dex.SearchPairs) -> Observable<DomainLayer.DTO.Dex.PairsSearch> {
        
       return Observable.zip(environmentRepository.servicesEnvironment(),
                             matcherRepository.matcherPublicKey())
            .flatMapLatest({ (servicesEnvironment, matcherPublicKey) -> Observable<DomainLayer.DTO.Dex.PairsSearch> in
                
                //TODO: Others type kinds
                guard case let .pairs(pairs) = query.kind else { return Observable.never() }
                
                
                let pairsForQuery = pairs.map { DataService.Query.PairsPrice.Pair(amountAssetId: $0.amountAsset,
                                                                                  priceAssetId: $0.priceAsset) }
                
                let query = DataService.Query.PairsPrice(pairs: pairsForQuery, matcher: matcherPublicKey.address)
                
                return servicesEnvironment
                    .wavesServices
                    .dataServices
                    .pairsPriceDataService
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
        })
    }
}
