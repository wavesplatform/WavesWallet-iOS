//
//  CandlesRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import Moya
import RxSwift
import WavesSDK

private enum Constants {
    static let matcherSwapAddress = "3PJaDyprvekvPXPuAtxrapacuDJopgJRaU3"
    static let matcherSwapTimestamp: TimeInterval = 1_575_288_000
    static let matcherSwapTimestamp1M: TimeInterval = 1_575_158_400
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

//TODO: Split usercase and services
final class CandlesRepositoryRemote: CandlesRepositoryProtocol {
        
    private let wavesSDKServices: WavesSDKServices
    
    private let matcherRepository: MatcherRepositoryProtocol
    private let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol

    private var internalMatcherSwapConfigs: DevelopmentConfigs?
    private var matcherSwapConfigs: DevelopmentConfigs? {
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

    init(matcherRepository: MatcherRepositoryProtocol,
         developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol,
         wavesSDKServices: WavesSDKServices) {
        
        self.wavesSDKServices = wavesSDKServices
        self.matcherRepository = matcherRepository
        self.developmentConfigsRepository = developmentConfigsRepository
    }

    func candles(serverEnvironment: ServerEnvironment,
                 amountAsset: String,
                 priceAsset: String,
                 timeStart: Date,
                 timeEnd: Date,
                 timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
        
        Observable.zip(matcherRepository.matcherPublicKey(serverEnvironment: serverEnvironment),
                       getMatcherSwapConfigs())
            .flatMap { publicKeyAccount, swapConfigs
                -> Observable<[DataService.Query.CandleFilters]> in

                let swapDate = swapConfigs.matcherSwapTimestamp
                let swapMatcherAddress = swapConfigs.matcherSwapAddress
                let timestampServerDiff = serverEnvironment.timestampServerDiff

                if timeStart.compare(swapDate) == .orderedAscending, timeEnd.compare(swapDate) == .orderedAscending {
                    let queryTimeStart = timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff)
                    let queryTimeEnd = timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff)

                    let queries = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                  priceAsset: priceAsset,
                                                                  timeStart: queryTimeStart,
                                                                  timeEnd: queryTimeEnd,
                                                                  interval: timeFrame.value,
                                                                  matcher: swapMatcherAddress)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)

                    return Observable.just(queries)
                } else if timeStart.compare(swapDate) == .orderedDescending, timeEnd.compare(swapDate) == .orderedDescending {
                    let queryTimeStart = timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff)
                    let queryTimeEnd = timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff)

                    let queries = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                  priceAsset: priceAsset,
                                                                  timeStart: queryTimeStart,
                                                                  timeEnd: queryTimeEnd,
                                                                  interval: timeFrame.value,
                                                                  matcher: publicKeyAccount.address)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)

                    return Observable.just(queries)
                } else if timeStart.compare(swapDate) == .orderedAscending, timeEnd.compare(swapDate) == .orderedDescending {
                    
                    let matcherSwapTimestamp1M = Date(timeIntervalSince1970: Constants.matcherSwapTimestamp1M)
                    let monthSwapDate = timeFrame == .M1 ? matcherSwapTimestamp1M : swapDate

                    let query1TimeStart = timeStart.millisecondsSince1970(timestampDiff: timestampServerDiff)
                    let query1TimeEnd = monthSwapDate.millisecondsSince1970(timestampDiff: timestampServerDiff)
                    let query1 = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                 priceAsset: priceAsset,
                                                                 timeStart: query1TimeStart,
                                                                 timeEnd: query1TimeEnd,
                                                                 interval: timeFrame.value,
                                                                 matcher: swapMatcherAddress)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)

                    let monthTimeStart = monthSwapDate.millisecondsSince1970(timestampDiff: timestampServerDiff)
                    let monthTimeEnd = timeEnd.millisecondsSince1970(timestampDiff: timestampServerDiff)
                    let query2 = DataService.Query.CandleFilters(amountAsset: amountAsset,
                                                                 priceAsset: priceAsset,
                                                                 timeStart: monthTimeStart,
                                                                 timeEnd: monthTimeEnd,
                                                                 interval: timeFrame.value,
                                                                 matcher: publicKeyAccount.address)
                        .normalizedCandleFiltersQueries(timeFrame: timeFrame)

                    return Observable.just(query1 + query2)
                }

                return Observable.just([])
            }
            .flatMap { [weak self] queries -> Observable<[DomainLayer.DTO.Candle]> in
                guard let self = self else { return Observable.never() }

                let obsQueries = queries.map {
                    self.candlesQuery(serverEnvironment: serverEnvironment, query: $0, timeFrame: timeFrame)
                }

                return Observable.zip(obsQueries).map { $0.flatMap { $0 } }
            }
    }
}

private extension CandlesRepositoryRemote {
    func candlesQuery(serverEnvironment: ServerEnvironment,
                      query: DataService.Query.CandleFilters,
                      timeFrame _: DomainLayer.DTO.Candle.TimeFrameType) -> Observable<[DomainLayer.DTO.Candle]> {
        
        return wavesSDKServices
            .wavesServices(environment: serverEnvironment)
            .dataServices            
            .candlesDataService
            .candles(query: query)
            .map { chart -> [DomainLayer.DTO.Candle] in
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

    // TODO: Refactor
    func getMatcherSwapConfigs() -> Observable<DevelopmentConfigs> {
        if let data = matcherSwapConfigs {
            return Observable.just(data)
        }

        return developmentConfigsRepository.developmentConfigs()
            .share(replay: 1, scope: .whileConnected)
            .flatMap { [weak self] configs -> Observable<DevelopmentConfigs> in
                guard let self = self else { return Observable.empty() }

                self.matcherSwapConfigs = configs
                return Observable.just(configs)
        }
        .catchError { (_) -> Observable<DevelopmentConfigs> in
                                    
            let matcherSwapTimestamp = Date(timeIntervalSince1970: Constants.matcherSwapTimestamp)
            
            let confing = DevelopmentConfigs(serviceAvailable: true,
                                                             matcherSwapTimestamp: matcherSwapTimestamp,
                                                             matcherSwapAddress: Constants.matcherSwapAddress,
                                                             exchangeClientSecret: "",
                                                             staking: [],
                                                             lockedPairs: [],
                                                             gatewayMinFee: [:],
                                                             marketPairs: [],
                                                             gatewayMinLimit: [:],
                                                             avaliableGatewayCryptoCurrency: [],
                                                             referralShare: 0)
            
            return Observable.just(confing)
        }
    }
}

extension DataService.Query.CandleFilters {
    func normalizedCandleFiltersQueries(timeFrame: DomainLayer.DTO.Candle.TimeFrameType) -> [DataService.Query.CandleFilters] {
        let timeFrame = Int64(timeFrame.rawValue)
        let minute: Int64 = 60 * 1000
        var timeStartMinute = Int64(floor(Double(timeStart) / Double(minute)))
        let timeEndMinute = Int64(ceil(Double(timeEnd) / Double(minute)))

        if (timeEndMinute - timeStartMinute) < timeFrame {
            timeStartMinute = timeEndMinute - timeFrame
        }

        var newTimeStartMinute = timeStartMinute
        var newTimeEndMinute = timeEndMinute

        var queries: [DataService.Query.CandleFilters] = .init()

        while newTimeStartMinute <= newTimeEndMinute {
            newTimeEndMinute = min(timeEndMinute, newTimeStartMinute + timeFrame * Constants.maxResolutionCandles)

            let normolizedQuery: DataService.Query.CandleFilters = .init(amountAsset: amountAsset,
                                                                         priceAsset: priceAsset,
                                                                         timeStart: newTimeStartMinute * minute,
                                                                         timeEnd: newTimeEndMinute * minute,
                                                                         interval: interval,
                                                                         matcher: matcher)

            queries.append(normolizedQuery)
            newTimeStartMinute = newTimeEndMinute + timeFrame
        }

        return queries
    }
}
