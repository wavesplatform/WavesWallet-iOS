//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift

public protocol DexPairsPriceRepositoryProtocol {
    
    func pairs(serverEnvironment: ServerEnvironment,
               accountAddress: String,
               pairs: [DomainLayer.DTO.Dex.SimplePair]) -> Observable<[DomainLayer.DTO.Dex.PairPrice]>
    
    func pairsRate(serverEnvironment: ServerEnvironment,
                   query: DomainLayer.Query.Dex.PairsRate) -> Observable<[DomainLayer.DTO.Dex.PairRate]>
    //TODO: Refactor searchPairs and search
    func searchPairs(serverEnvironment: ServerEnvironment,
                     query: DomainLayer.Query.Dex.SearchPairs) -> Observable<DomainLayer.DTO.Dex.PairsSearch>
    
    func search(serverEnvironment: ServerEnvironment,                
                searchText: String) -> Observable<[DomainLayer.DTO.Dex.SimplePair]>
}
