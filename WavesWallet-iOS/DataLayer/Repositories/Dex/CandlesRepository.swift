//
//  CandlesRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import Moya

final class CandlesRepository: CandlesRepositoryProtocol {
    
    private let apiProvider: MoyaProvider<API.Service.Candles> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let auth = FactoryInteractors.instance.authorization
    private let environment = FactoryRepositories.instance.environmentRepository
    
    func candles(amountAsset: String, priceAsset: String, timeStart: Date, timeEnd: Date, timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
 
        return auth.authorizedWallet().flatMap({ (wallet) -> Observable<[DomainLayer.DTO.Candle]> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ (environment) -> Observable<[DomainLayer.DTO.Candle]> in
                    
                    let filters = API.Query.CandleFilters(timeStart: Int64(timeStart.timeIntervalSince1970 * 1000),
                                                          timeEnd: Int64(timeEnd.timeIntervalSince1970 * 1000),
                                                          interval: String(timeFrame.rawValue) + "m")
                    
                    let candles = API.Service.Candles(amountAsset: amountAsset,
                                                     priceAsset: priceAsset,
                                                     params: filters,
                                                     environment: environment)
                    
                    return self.apiProvider.rx
                    .request(candles)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(API.DTO.Chart.self)
                    .asObservable()
                    .map({ [weak self] (chart) -> [DomainLayer.DTO.Candle] in
                        
                        guard let owner = self else { return [] }
                            
                        var models: [DomainLayer.DTO.Candle] = []
                        
                        for model in chart.candles {
                            
                            if model.volume > 0 {
                                let timestamp = owner.convertTimestamp(model.time, timeFrame: timeFrame)
                                
                                let model = DomainLayer.DTO.Candle(close: model.close,
                                                                   high: model.high,
                                                                   low: model.low,
                                                                   open: model.open,
                                                                   timestamp: timestamp,
                                                                   volume: model.volume)
                                models.append(model)
                            }
                        }
                        
                        return models
                    })
                })
        })
    }
}

private extension CandlesRepository {
    
    func convertTimestamp(_ timestamp: Int64, timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Double {
        return Double(timestamp / Int64(1000 * 60 * timeFrame.rawValue))
    }
}


