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
    
    func pairs() -> Observable<[DomainLayer.DTO.Dex.AssetPair]>
    func searchPairs() -> Observable<[DomainLayer.DTO.Dex.AssetPair]>
    func checkMark(pair: DomainLayer.DTO.Dex.AssetPair)
    func searchPair(searchText: String)
}
