//
//  CandlesRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer
import Extensions

private enum Constants {
    static let matcherSwapAddress = "3PJaDyprvekvPXPuAtxrapacuDJopgJRaU3"
    static let matcherSwapTimestamp: TimeInterval = 1575288000
}

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
            
        case .M1:
            return "1M"
                
        case .W1:
            return "1w"
            
        case .h24:
            return "1d"
            
        case .h4:
            return "4h"
            
        }
    }
}


final class CandlesRepositoryRemote: CandlesRepositoryProtocol {
    
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    private let matcherRepository: MatcherRepositoryProtocol
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol

    private var internalMatcherSwapConfigs: DomainLayer.DTO.DevelopmentConfigs?
    private var matcherSwapConfigs: DomainLayer.DTO.DevelopmentConfigs? {
        get {
           objc_sync_enter(self)
           defer { objc_sync_exit(self) }
           return internalMatcherSwapConfigs
       }
       
       set {
           objc_sync_enter(self)
           defer { objc_sync_exit(self) }
           internalMatcherSwapConfigs = newValue
       }
    }

    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols,
         matcherRepository: MatcherRepositoryProtocol,
         developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol) {
        
        self.environmentRepository = environmentRepository
        self.matcherRepository = matcherRepository
        self.developmentConfigsRepository = developmentConfigsRepository
    }
    
    func candles(amountAsset: String,
                 priceAsset: String,
                 timeStart: Date,
                 timeEnd: Date,
                 timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
 
        
        return Observable.zip(environmentRepository.servicesEnvironment(),
                              matcherRepository.matcherPublicKey(),
                              getMatcherSwapConfigs())
            .flatMap{ [weak self] (servicesEnvironment, publicKeyAccount, swapConfigs) -> Observable<[DomainLayer.DTO.Candle]> in
                guard let self = self else { return Observable.empty() }

                let swapDate = swapConfigs.matcherSwapTimestamp
                let swapMatcherAddress = swapConfigs.matcherSwapAddress
                let timestampServerDiff = servicesEnvironment.timestampServerDiff
                                
                if timeStart.compare(swapDate) == .orderedAscending && timeEnd.compare(swapDate) == .orderedAscending {
                    
                    let query = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                priceAsset: priceAsset,
                                                                timeStart: timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                timeEnd: timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                interval: timeFrame.value,
                                                                matcher: swapMatcherAddress)
                    
                    return self.candlesQuery(servicesEnvironment: servicesEnvironment, query: query, timeFrame: timeFrame)
                }
                    
                else if timeStart.compare(swapDate) == .orderedDescending && timeEnd.compare(swapDate) == .orderedDescending {
                    let query = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                priceAsset: priceAsset,
                                                                timeStart: timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                timeEnd: timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                interval: timeFrame.value,
                                                                matcher: publicKeyAccount.address)
                    
                    return self.candlesQuery(servicesEnvironment: servicesEnvironment, query: query, timeFrame: timeFrame)
                }
                else if timeStart.compare(swapDate) == .orderedAscending && timeEnd.compare(swapDate) == .orderedDescending {
                
                    let query1 = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                 priceAsset: priceAsset,
                                                                 timeStart: timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 timeEnd: swapDate.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 interval: timeFrame.value,
                                                                 matcher: swapMatcherAddress)
                    
                    let query2 = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                 priceAsset: priceAsset,
                                                                 timeStart: swapDate.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 timeEnd: timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 interval: timeFrame.value,
                                                                 matcher: publicKeyAccount.address)
                    
                    let candlesQuery1 = self.candlesQuery(servicesEnvironment: servicesEnvironment, query: query1, timeFrame: timeFrame)
                    let candlesQuery2 = self.candlesQuery(servicesEnvironment: servicesEnvironment, query: query2, timeFrame: timeFrame)
                    
                    return Observable.zip(candlesQuery1, candlesQuery2)
                        .map { candles1, candles2 -> [DomainLayer.DTO.Candle] in
                            return candles1 + candles2
                    }
                }
                
                return Observable.just([])
        }
    }
}


private extension CandlesRepositoryRemote {
    
    func candlesQuery(servicesEnvironment: ApplicationEnviroment, query: DataService.Query.CandleFilters, timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
        
        return servicesEnvironment
            .wavesServices
            .dataServices
            .candlesDataService
            .candles(query: query)
            .map{ (chart) -> [DomainLayer.DTO.Candle] in
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
           }
    }
    
    func getMatcherSwapConfigs() -> Observable<DomainLayer.DTO.DevelopmentConfigs> {
        
        if let data = matcherSwapConfigs {
            return Observable.just(data)
        }
        
        return developmentConfigsRepository.developmentConfigs()
            .share(replay: 1, scope: .whileConnected)
            .flatMap { [weak self] configs -> Observable<DomainLayer.DTO.DevelopmentConfigs> in
                guard let self = self else { return Observable.empty() }
                
                self.matcherSwapConfigs = configs
                return Observable.just(configs)
        }
        .catchError { (_) -> Observable<DomainLayer.DTO.DevelopmentConfigs> in
            let confing = DomainLayer.DTO.DevelopmentConfigs(serviceAvailable: true,
                                                             matcherSwapTimestamp: Date(timeIntervalSince1970: Constants.matcherSwapTimestamp),
                                                             matcherSwapAddress: Constants.matcherSwapAddress)
            
            return Observable.just(confing)
        }
    }
    
    func convertTimestamp(_ timestamp: Int64, timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Double {
        return Double(timestamp / Int64(1000 * 60 * timeFrame.rawValue))
    }
}


