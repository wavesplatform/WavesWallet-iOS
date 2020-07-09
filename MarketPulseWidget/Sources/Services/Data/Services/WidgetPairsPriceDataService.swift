//
//  PairsPriceDataService.swift
//  Alamofire
//
//  Created by rprokofev on 06/05/2019.
//

import DataLayer
import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK

extension WidgetDataService.DTO {
    struct Rate {
        let amountAssetId: String
        let priceAssetId: String
        let rate: Double
    }
}

extension WidgetDataService.Query {
    struct Rates {
        struct Pair {
            let amountAssetId: String
            let priceAssetId: String
        }

        let pair: [Pair]
        let matcher: String
        let timestamp: Date?
    }
}

private struct Rate: Decodable {
    struct Data: Decodable {
        let rate: Double
    }

    let data: Data
    let amountAsset: String
    let priceAsset: String
}

protocol WidgetPairsPriceDataServiceProtocol {
    func pairsPrice(query: WidgetDataService.Query.PairsPrice) -> Observable<[WidgetDataService.DTO.PairPrice?]>
    func pairsRate(query: WidgetDataService.Query.Rates) -> Observable<[WidgetDataService.DTO.Rate]>
}

final class WidgetPairsPriceDataService: WidgetPairsPriceDataServiceProtocol {
    private let pairsPriceProvider: MoyaProvider<WidgetDataService.Target.PairsPrice> = InternalWidgetService.moyaProvider()

    private let matcherRatesProvider: MoyaProvider<WidgetDataService.Target.MatcherRates> = InternalWidgetService.moyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func pairsRate(query: WidgetDataService.Query.Rates) -> Observable<[WidgetDataService.DTO.Rate]> {
        return environmentRepository.walletEnvironment()
            .flatMap { [weak self] environment -> Observable<[WidgetDataService.DTO.Rate]> in

                guard let self = self else { return Observable.never() }

                return self
                    .matcherRatesProvider
                    .rx
                    .request(.init(query: query.query,
                                   dataUrl: environment.servers.dataUrl),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError { (error) -> Single<Response> in
                        Single<Response>.error(NetworkError.error(by: error))
                    }
                    .map(WidgetDataService.Response<[Rate]>.self)
                    .map { $0.data.map { WidgetDataService.DTO.Rate(amountAssetId: $0.amountAsset,
                                                                    priceAssetId: $0.priceAsset,
                                                                    rate: $0.data.rate) } }
                    .asObservable()
            }
    }

    func pairsPrice(query: WidgetDataService.Query.PairsPrice) -> Observable<[WidgetDataService.DTO.PairPrice?]> {
        return environmentRepository.walletEnvironment()
            .flatMap { [weak self] walletEnvironment -> Observable<[WidgetDataService.DTO.PairPrice?]> in

                guard let self = self else { return Observable.never() }
                                
                return self.pairsPriceProvider
                    .rx
                    .request(.init(query: query,
                                   dataUrl: walletEnvironment.servers.dataUrl),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError { (error) -> Single<Response> in
                        Single<Response>.error(NetworkError.error(by: error))
                    }
                    .map(WidgetDataService.Response<[WidgetDataService.OptionalResponse<WidgetDataService.DTO.PairPrice>]>.self)
                    .map { $0.data.map { $0.data } }
                    .asObservable()
            }
    }
}

fileprivate extension WidgetDataService.Query.Rates {
    var query: WidgetDataService.Query.MatcherRates {
        return WidgetDataService.Query.MatcherRates(pairs: pair.map { .init(amountAssetId: $0.amountAssetId,
                                                                            priceAssetId: $0.priceAssetId) },
                                                    matcher: matcher,
                                                    timestamp: timestamp?.millisecondsSince1970)
    }
}
