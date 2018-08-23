//
//  DexLastTradesInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class DexLastTradesInteractor: DexLastTradesInteractorProtocol {
 
    var pair: DexTraderContainer.DTO.Pair!

    func trades() -> Observable<([DexLastTrades.DTO.Trade])> {
        return Observable.empty()
    }
}
