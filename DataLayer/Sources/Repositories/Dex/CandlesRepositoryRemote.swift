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
import DomainLayer
import Extensions


private extension DomainLayer.DTO.Candle.TimeFrameType {
    
    var value: String {
        switch self {
        case .m5:
            return "5m"
            
        case .m15:
            return "15m"
            
        case .m30:
            return "30m"
            
        case .h1:
            return "1h"
            
        case .h3:
            return "3h"
            
        case .h24:
            return "1d"
        }
    }
}


final class CandlesRepositoryRemote: CandlesRepositoryProtocol {
    
    private let environmentRepository: EnvironmentRepositoryProtocols
    private let matcherRepository: MatcherRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocols, matcherRepository: MatcherRepositoryProtocol) {
        self.environmentRepository = environmentRepository
        self.matcherRepository = matcherRepository
    }
    
    func candles(amountAsset: String,
                 priceAsset: String,
                 timeStart: Date,
                 timeEnd: Date,
                 timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
 
        
        return Observable.zip(environmentRepository.servicesEnvironment(), matcherRepository.matcherPublicKey())
            .flatMap({ [weak self] (servicesEnvironment, publicKeyAccount) -> Observable<[DomainLayer.DTO.Candle]> in
                guard let self = self else { return Observable.empty() }

                
                let timestampServerDiff = servicesEnvironment.timestampServerDiff
                
                let candles = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                              priceAsset: priceAsset,
                                                              timeStart: timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                              timeEnd: timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                              interval: timeFrame.value,
                                                              matcher: publicKeyAccount.address)
                return servicesEnvironment
                .wavesServices
                .dataServices
                .candlesDataService
                .candles(query: candles)
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
                            let timestamp = self.convertTimestamp(Int64(model.time.timeIntervalSince1970 * 1000), timeFrame: timeFrame)
                            
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


