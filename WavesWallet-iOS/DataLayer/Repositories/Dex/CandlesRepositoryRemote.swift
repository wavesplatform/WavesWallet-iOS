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

final class CandlesRepositoryRemote: CandlesRepositoryProtocol {
    
    private let apiProvider: MoyaProvider<API.Service.Candles> = .nodeMoyaProvider()
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func candles(accountAddress: String, amountAsset: String, priceAsset: String, timeStart: Date, timeEnd: Date, timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
 
        return environmentRepository.accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Candle]> in
                
                guard let self = self else { return Observable.empty() }
                
                let filters = API.Query.CandleFilters(timeStart: timeStart.millisecondsSince1970(timestampDiff: environment.timestampServerDiff),
                                                      timeEnd: timeEnd.millisecondsSince1970(timestampDiff: environment.timestampServerDiff),
                                                      interval: String(timeFrame.rawValue) + "m")
                
                let candles = API.Service.Candles(amountAsset: amountAsset,
                                                  priceAsset: priceAsset,
                                                  params: filters,
                                                  environment: environment)
                
                return self.apiProvider.rx
                    .request(candles, callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(API.DTO.Chart.self)
                    .asObservable()
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


