//
//  DexMarketInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexMarketInteractorProtocol {
    
    func pairs() -> Observable<[DexMarket.DTO.Pair]>
    func searchPairs() -> Observable<[DexMarket.DTO.Pair]>
    func checkMark(pair: DexMarket.DTO.Pair)
    func searchPair(searchText: String)
}
