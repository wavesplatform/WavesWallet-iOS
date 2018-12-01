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
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func candles(timeFrame: DexChart.DTO.TimeFrameType, timeStart: Date, timeEnd: Date) -> Observable<[DexChart.DTO.Candle]> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            let path = Environments.current.servers.dataUrl.relativeString + "/candles/\(self.pair.amountAsset.id)/\(self.pair.priceAsset.id)"
            
            let params = [Constants.timeStart : Int64(timeStart.timeIntervalSince1970 * 1000),
                          Constants.timeEnd : Int64(timeEnd.timeIntervalSince1970 * 1000),
                          Constants.interval : String(timeFrame.rawValue) + "m"] as [String : Any]
            
            NetworkManager.getRequestWithUrl(path, parameters: params, complete: { (info, error) in
               
                var models: [DexChart.DTO.Candle] = []

                if let items = info?["candles"].arrayValue {
                    
                    for item in items {
                        
                        let volume = item["volume"].doubleValue
                        if volume > 0 {
                            
                            let timestamp = self.convertTimestamp(item["time"].int64Value, timeFrame: timeFrame)
                            
                            let model = DexChart.DTO.Candle(close: item["close"].doubleValue,
                                                            high: item["high"].doubleValue,
                                                            low: item["low"].doubleValue,
                                                            open: item["open"].doubleValue,
                                                            timestamp: timestamp,
                                                            volume: volume)
                            models.append(model)
                        }
                    }
                }
                subscribe.onNext(models)
            })
    

            return Disposables.create()
        })
    }
    
   
   
}

private extension DexChartInteractor {
    
    func convertTimestamp(_ timestamp: Int64, timeFrame: DexChart.DTO.TimeFrameType) -> Double {
        return Double(timestamp / Int64(1000 * 60 * timeFrame.rawValue))
    }
}
