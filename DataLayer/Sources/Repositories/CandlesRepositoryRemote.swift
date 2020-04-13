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
    static let matcherSwapTimestamp1M: TimeInterval = 1575158400
    static let minute: Int64 = 1000 * 60
    static let maxResolutionCandles: Int64 = 1440
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
            
        case .h2:
            return "2h"
            
        case .h3:
            return "3h"
            
        case .h4:
            return "4h"
            
        case .h6:
            return "6h"
        
        case .h12:
            return "12h"
            
        case .h24:
            return "1d"
                                    
        case .W1:
            return "1w"
            
        case .M1:
            return "1M"
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
            .flatMap{ (servicesEnvironment,
                        publicKeyAccount,
                        swapConfigs) -> Observable<(queries: [DataService.Query.CandleFilters],
                                                    servicesEnvironment: ApplicationEnviroment)> in
                
                let swapDate = swapConfigs.matcherSwapTimestamp
                let swapMatcherAddress = swapConfigs.matcherSwapAddress
                let timestampServerDiff = servicesEnvironment.timestampServerDiff
                                
                if timeStart.compare(swapDate) == .orderedAscending && timeEnd.compare(swapDate) == .orderedAscending {
                    
                    let queries = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                priceAsset: priceAsset,
                                                                timeStart: timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                timeEnd: timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                interval: timeFrame.value,
                        matcher: swapMatcherAddress)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)
                    
   
                    return Observable.just((queries: queries, servicesEnvironment: servicesEnvironment))
                } else if timeStart.compare(swapDate) == .orderedDescending && timeEnd.compare(swapDate) == .orderedDescending {
                    let queries = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                priceAsset: priceAsset,
                                                                timeStart: timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                timeEnd: timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                interval: timeFrame.value,
                                                                matcher: publicKeyAccount.address)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)
                    return Observable.just((queries: queries, servicesEnvironment: servicesEnvironment))
                } else if timeStart.compare(swapDate) == .orderedAscending && timeEnd.compare(swapDate) == .orderedDescending {
                
                    let monthSwapDate = timeFrame == .M1 ? Date(timeIntervalSince1970: Constants.matcherSwapTimestamp1M) : swapDate
                    
                    let query1 = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                 priceAsset: priceAsset,
                                                                 timeStart: timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 timeEnd: monthSwapDate.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 interval: timeFrame.value,
                                                                 matcher: swapMatcherAddress)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)
                    
                    let query2 = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                 priceAsset: priceAsset,
                                                                 timeStart: monthSwapDate.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 timeEnd: timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff),
                                                                 interval: timeFrame.value,
                        matcher: publicKeyAccount.address)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)
                                        
                    return Observable.just((queries: query1 + query2, servicesEnvironment: servicesEnvironment))
                }
                
                return Observable.just((queries: [], servicesEnvironment: servicesEnvironment))
        }
        .flatMap { [weak self] (data) -> Observable<[DomainLayer.DTO.Candle]> in
            guard let self = self else { return Observable.never() }
            
            let obsQueries = data.queries.map { self.candlesQuery(servicesEnvironment: data.servicesEnvironment,
                                                                  query: $0,
                                                                  timeFrame: timeFrame) }
                        
            return Observable
                .zip(obsQueries)
                .map { $0.flatMap { $0 } }
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

                       let model = DomainLayer.DTO.Candle(close: close,
                                                          high: high,
                                                          low: low,
                                                          open: open,
                                                          timestamp: model.time,
                                                          volume: volume)
                       models.append(model)
                   }
               }
               
               return models
           }
    }
    
    //TODO: Refactor
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
                                    
            let matcherSwapTimestamp = Date(timeIntervalSince1970: Constants.matcherSwapTimestamp)
            
            let confing = DomainLayer.DTO.DevelopmentConfigs(serviceAvailable: true,
                                                             matcherSwapTimestamp: matcherSwapTimestamp,
                                                             matcherSwapAddress: Constants.matcherSwapAddress,
                                                             exchangeClientSecret: "",
                                                             staking: [],
                                                             lockedPairs: [],
                                                             gatewayMinFee: [:],
                                                             marketPairs: [])
            
            return Observable.just(confing)
        }
    }

}



extension DataService.Query.CandleFilters {
    
    func normalizedCandleFiltersQueries(timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> [DataService.Query.CandleFilters] {
                        
        let timeFrame: Int64 = Int64(timeFrame.rawValue)
        let minute: Int64 = 60 * 1000
        var timeStartMinute = Int64(floor(Double(timeStart) / Double(minute)))
        let timeEndMinute = Int64(ceil(Double(timeEnd) / Double(minute)))
        
        if ((timeEndMinute - timeStartMinute) < timeFrame) {
            timeStartMinute = timeEndMinute - timeFrame
        }
        
    
        var newTimeStartMinute = timeStartMinute
        var newTimeEndMinute = timeEndMinute
        
        var queries: [DataService.Query.CandleFilters] = .init()
        
        while newTimeStartMinute <= newTimeEndMinute {
            
            newTimeEndMinute = min(timeEndMinute, newTimeStartMinute + timeFrame * Constants.maxResolutionCandles)
            
            let normolizedQuery: DataService.Query.CandleFilters = .init(amountAsset: self.amountAsset,
                                                                         priceAsset: self.priceAsset,
                                                                         timeStart: newTimeStartMinute * minute,
                                                                         timeEnd: newTimeEndMinute * minute,
                                                                         interval: self.interval,
                                                                         matcher: self.matcher)
            
            queries.append(normolizedQuery)
            newTimeStartMinute = newTimeEndMinute + timeFrame;
        }
    
        return queries
    }
}
