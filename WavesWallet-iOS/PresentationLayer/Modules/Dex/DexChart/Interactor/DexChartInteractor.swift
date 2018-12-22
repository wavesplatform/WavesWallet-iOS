//
//  DexChartInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

private enum Constants {
    static let timeStart = "timeStart"
    static let timeEnd = "timeEnd"
    static let interval = "interval"
}

final class DexChartInteractor: DexChartInteractorProtocol {
    
    private let candlesReposotiry = FactoryRepositories.instance.candlesRepository
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func candles(timeFrame: DomainLayer.DTO.Candle.TimeFrameType, timeStart: Date, timeEnd: Date) -> Observable<[DomainLayer.DTO.Candle]> {
        return candlesReposotiry.candles(amountAsset: pair.amountAsset.id,
                                         priceAsset: pair.priceAsset.id,
                                         timeStart: timeStart,
                                         timeEnd: timeEnd,
                                         timeFrame: timeFrame)
        .catchError({ (error) -> Observable<[DomainLayer.DTO.Candle]> in
            return Observable.just([])
        })
    }
}
