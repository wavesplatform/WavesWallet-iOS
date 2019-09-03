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

protocol WidgetPairsPriceDataServiceProtocol {
    func pairsPrice(query: WidgetDataService.Query.PairsPrice) -> Observable<[WidgetDataService.DTO.PairPrice?]>
}


final class WidgetPairsPriceDataService: WidgetPairsPriceDataServiceProtocol {

    private let pairsPriceProvider: MoyaProvider<WidgetDataService.Target.PairsPrice> = InternalWidgetService.moyaProvider()

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
