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
                            let firstPrice = Money(value: Decimal(pair.firstPrice), priceAsset.decimals)
                            let lastPrice = Money(value: Decimal(pair.lastPrice), priceAsset.decimals)
                            
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
