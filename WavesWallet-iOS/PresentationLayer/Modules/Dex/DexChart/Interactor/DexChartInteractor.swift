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


final class DexChartInteractor: DexChartInteractorProtocol {
    
    var pair: DexTraderContainer.DTO.Pair!
 
    func candles(timeFrame: DexChart.DTO.TimeFrameType, dateFrom: Date, dateTo: Date) -> Observable<([DexChart.DTO.Candle])> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            let dateFrom = String(format: "%0.f", dateFrom.timeIntervalSince1970 * 1000)
            let dateTo =  String(format: "%0.f", dateTo.timeIntervalSince1970 * 1000)
            
            //TODO: need change to Observer network
            let url = GlobalConstants.Market.candles + "\(self.pair.amountAsset.id)/\(self.pair.priceAsset.id)/\(timeFrame.rawValue)/\(dateFrom)/\(dateTo)"
            
            NetworkManager.getRequestWithUrl(url, parameters: nil, complete: { (info, error) in
               
                var models: [DexChart.DTO.Candle] = []

                if let items = info?.arrayValue {
                    for item in items {
                        
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
            })
    

            return Disposables.create()
        })
    }
    
    private func convertTimestamp(_ timestamp: Int64, timeFrame: DexChart.DTO.TimeFrameType) -> Double {
        return Double(timestamp / Int64(1000 * 60 * timeFrame.rawValue))
    }
}
