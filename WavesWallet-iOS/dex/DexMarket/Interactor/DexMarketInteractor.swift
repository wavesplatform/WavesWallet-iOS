//
//  DexMarketInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexMarketInteractor: DexMarketInteractorProtocol {
 
    func pairs() -> Observable<[DexMarket.DTO.Pair]> {
        return Observable.just([])
    }
    
    func checkMark(pair: DexMarket.DTO.Pair) {
        
    }
}
