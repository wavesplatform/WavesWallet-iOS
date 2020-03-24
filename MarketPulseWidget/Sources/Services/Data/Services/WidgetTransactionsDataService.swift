//
//  WidgetTransactionsDataService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 29.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKExtensions

final class WidgetTransactionsDataService: TransactionsDataServiceProtocol {
    private let transactionsProvider: MoyaProvider<WidgetDataService.Target.Transactions> = InternalWidgetService.moyaProvider()
    
    func transactionsExchange(query: DataService.Query.ExchangeFilters) -> Observable<[DataService.DTO.ExchangeTransaction]> {
        return self
            .transactionsProvider
            .rx
            .request(.init(kind: .getExchangeWithFilters(query),
                           dataUrl: InternalWidgetService.shared.dataUrl,
                           matcher: query.matcher),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError { (error) -> Single<Response> in
                Single<Response>.error(NetworkError.error(by: error))
            }
            .map(WidgetDataService.Response<[WidgetDataService.Response<DataService.DTO.ExchangeTransaction>]>.self,
                 atKeyPath: nil,
                 using: JSONDecoder.isoDecoderBySyncingTimestamp(0),
                 failsOnEmptyData: false)
            .map { $0.data.map { $0.data } }
            .asObservable()
    }
    
    func getMassTransferTransactions(query: DataService.Query.MassTransferDataQuery) -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> {
        Observable.never()
    }
}
