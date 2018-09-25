//
//  DexChartInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


final class DexChartInteractor: DexChartInteractorProtocol {
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func candles(timeFrame: DexChart.DTO.TimeFrameType, dateFrom: Date, dateTo: Date) -> Observable<([DexChart.DTO.Candle])> {
        return Observable.empty()
    }
}
