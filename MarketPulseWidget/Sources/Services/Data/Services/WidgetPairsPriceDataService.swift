//
//  PairsPriceDataService.swift
//  Alamofire
//
//  Created by rprokofev on 06/05/2019.
//

import Foundation
import RxSwift
import Moya
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

    func pairsRate(query: WidgetDataService.Query.Rates) -> Observable<[WidgetDataService.DTO.Rate]> {
        
        return self
            .matcherRatesProvider
            .rx
            .request(.init(query: query.query,
                           dataUrl: InternalWidgetService.shared.dataUrl),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Single<Response> in
                return Single<Response>.error(NetworkError.error(by: error))
            })
            .map(WidgetDataService.Response<[Rate]>.self)
            .map { $0.data.map { WidgetDataService.DTO.Rate.init(amountAssetId: $0.amountAsset,
                                                                 priceAssetId: $0.priceAsset,
                                                                 rate: $0.data.rate) }}
            .asObservable()
    }
    
    func pairsPrice(query: WidgetDataService.Query.PairsPrice) -> Observable<[WidgetDataService.DTO.PairPrice?]> {

        return self
            .pairsPriceProvider
            .rx
            .request(.init(query: query,
                           dataUrl: InternalWidgetService.shared.dataUrl),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Single<Response> in
                return Single<Response>.error(NetworkError.error(by: error))
            })
            .map(WidgetDataService.Response<[WidgetDataService.OptionalResponse<WidgetDataService.DTO.PairPrice>]>.self)
            .map { $0.data.map {$0.data }}
            .asObservable()
    }

}
fileprivate extension WidgetDataService.Query.Rates {
    
    var query: WidgetDataService.Query.MatcherRates {
        return WidgetDataService.Query.MatcherRates(pairs: pair.map { .init(amountAssetId: $0.amountAssetId,
                                                                            priceAssetId: $0.priceAssetId) },
                                                    matcher: matcher)
    }
}
