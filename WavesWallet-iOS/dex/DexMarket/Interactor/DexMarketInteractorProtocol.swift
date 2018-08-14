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
    
    func pairs() -> Observable<[DexMarket.DTO.AssetPair]>
    func searchPairs() -> Observable<[DexMarket.DTO.AssetPair]>
    func checkMark(pair: DexMarket.DTO.AssetPair)
    func searchPair(searchText: String)
}
