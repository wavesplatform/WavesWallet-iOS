//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer
import Extensions

final class DexPairsPriceRepositoryRemote: DexPairsPriceRepositoryProtocol {
  
    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
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

        return environmentRepository
        .servicesEnvironment()
            .flatMap({ (servicesEnvironment) -> Observable<[DomainLayer.DTO.Dex.SimplePair]> in
                return servicesEnvironment
                .wavesServices
                .dataServices
                .pairsPriceDataService
                .searchByAsset(query: .init(kind: kind))
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
    
    func list(by accountAddress: String,
              pairs: [DomainLayer.DTO.Dex.Pair]) -> Observable<[DomainLayer.DTO.Dex.PairPrice]> {

        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ (servicesEnvironment) -> Observable<[DomainLayer.DTO.Dex.PairPrice]> in
                
                let pairsForQuery = pairs.map { DataService.Query.PairsPrice.Pair(amountAssetId: $0.amountAsset.id,
                                                                                  priceAssetId: $0.priceAsset.id) }
                
                let query = DataService.Query.PairsPrice(pairs: pairsForQuery)
                
                return servicesEnvironment
                    .wavesServices
                    .dataServices
                    .pairsPriceDataService
                    .pairsPrice(query: query)
                    .map({ (list) -> [DomainLayer.DTO.Dex.PairPrice] in
                        
                        var listPairs: [DomainLayer.DTO.Dex.PairPrice] = []
                        
                        for (index, pair) in list.enumerated() {
                            let localPair = pairs[index]
                            
                            let priceAsset = localPair.priceAsset
                            let firstPrice = Money(value: Decimal(pair?.firstPrice ?? 0), priceAsset.decimals)
                            let lastPrice = Money(value: Decimal(pair?.lastPrice ?? 0), priceAsset.decimals)
                            
                            let pair = DomainLayer.DTO.Dex.PairPrice(firstPrice: firstPrice,
                                                                     lastPrice: lastPrice,
                                                                     amountAsset: localPair.amountAsset,
                                                                     priceAsset: priceAsset)
                            listPairs.append(pair)
                        }
                        
                        return listPairs
                    })
            })
    }
}
