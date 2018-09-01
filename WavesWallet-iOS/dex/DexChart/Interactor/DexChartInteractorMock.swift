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


final class DexChartInteractorMock: DexChartInteractorProtocol {
    
    var pair: DexTraderContainer.DTO.Pair!
 
    func candles(timeFrame: DexChart.DTO.TimeFrameType, dateFrom: Date, dateTo: Date) -> Observable<([DexChart.DTO.Candle])> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            NetworkManager.getCandles(amountAsset: self.pair.amountAsset.id, priceAsset: self.pair.priceAsset.id, timeframe: timeFrame.rawValue, from: dateFrom, to: dateTo) { (items: NSArray?, errorMessage: String?) in
                
                var models: [DexChart.DTO.Candle] = []
                
                if let items = items {
                    
                    for item in JSON(items).arrayValue {
                        
                        let volume = item["volume"].doubleValue
                        if volume > 0 {

                            let timestamp = self.convertTimestamp(item["timestamp"].int64Value, timeFrame: timeFrame)
                          
                            let model = DexChart.DTO.Candle(close: item["close"].doubleValue,
                                                            confirmed: item["confirmed"].boolValue,
                                                            high: item["high"].doubleValue,
                                                            low: item["low"].doubleValue,
                                                            open: item["open"].doubleValue,
                                                            priceVolume: item["priceVolume"].doubleValue,
                                                            timestamp: timestamp,
                                                            volume: volume,
                                                            vwap: item["vwap"].doubleValue)
                            models.append(model)
                        }
                    }
                }
                
                subscribe.onNext(models)
            }

            return Disposables.create()
        })
    }
    
    private func convertTimestamp(_ timestamp: Int64, timeFrame: DexChart.DTO.TimeFrameType) -> Double {
        return Double(timestamp / Int64(1000 * 60 * timeFrame.rawValue))
    }
}
