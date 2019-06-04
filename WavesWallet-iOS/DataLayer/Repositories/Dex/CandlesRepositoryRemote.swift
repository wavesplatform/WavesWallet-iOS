//
//  CandlesRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK

final class CandlesRepositoryRemote: CandlesRepositoryProtocol {
    
    private let candlesDataService =  ServicesFactory.shared.candlesDataService
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func candles(accountAddress: String,
                 amountAsset: String,
                 priceAsset: String,
                 timeStart: Date,
                 timeEnd: Date,
                 timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
 
        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Candle]> in
                
                guard let self = self else { return Observable.empty() }
                
                let candles = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                              priceAsset: priceAsset,
                                                              timeStart: timeStart.millisecondsSince1970(timestampDiff: environment.timestampServerDiff),
                                                              timeEnd: timeEnd.millisecondsSince1970(timestampDiff: environment.timestampServerDiff),
                                                              interval: String(timeFrame.rawValue) + "m")
                return self
                    .candlesDataService
                    .candles(query: candles, enviroment: environment.environmentServiceData)
                    .map({ (chart) -> [DomainLayer.DTO.Candle] in
                        
                        var models: [DomainLayer.DTO.Candle] = []
                        
                        for model in chart.candles {
                            
                            guard let volume = model.volume,
                            let high = model.high,
                            let low = model.low,
                            let open = model.open,
                            let close = model.close else {
                                continue
                            }
                            
                            if volume > 0 {
                                let timestamp = self.convertTimestamp(model.time, timeFrame: timeFrame)
                                
                                let model = DomainLayer.DTO.Candle(close: close,
                                                                   high: high,
                                                                   low: low,
                                                                   open: open,
                                                                   timestamp: timestamp,
                                                                   volume: volume)
                                models.append(model)
                            }
                        }
                        
                        return models
                    })
            })
    }
}

private extension CandlesRepositoryRemote {
    
    func convertTimestamp(_ timestamp: Int64, timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Double {
        return Double(timestamp / Int64(1000 * 60 * timeFrame.rawValue))
    }
}


