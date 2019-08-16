//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol DexPairsPriceRepositoryProtocol {
    

    func list(pairs: [DomainLayer.DTO.Dex.Pair]) -> Observable<[DomainLayer.DTO.Dex.PairPrice]>

    //TODO: Refactor searchPairs and search
    func searchPairs(_ query: DomainLayer.Query.Dex.SearchPairs) -> Observable<DomainLayer.DTO.Dex.PairsSearch>
    
    func search(by accountAddress: String, searchText: String) -> Observable<[DomainLayer.DTO.Dex.SimplePair]>

}
