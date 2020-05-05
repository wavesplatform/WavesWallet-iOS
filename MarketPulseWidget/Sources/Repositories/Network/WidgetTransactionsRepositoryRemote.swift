//
//  WidgetTransactionsRepositoryRemote.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 29.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK

protocol WidgetTransactionsRepositoryProtocol {
    func exchangeTransactions(amountAsset: String,
                              priceAsset: String,
                              limit: Int) -> Observable<[DataService.DTO.ExchangeTransaction]>
}

final class WidgetTransactionsRepositoryRemote: WidgetTransactionsRepositoryProtocol {
    private let transactionsDataService: TransactionsDataServiceProtocol = WidgetTransactionsDataService()
    private let matcherRepository = WidgetMatcherRepositoryRemote()

    func exchangeTransactions(amountAsset: String,
                              priceAsset: String,
                              limit: Int) -> Observable<[DataService.DTO.ExchangeTransaction]> {
        matcherRepository
            .matcherPublicKey()
            .flatMap { [weak self] publicKeyAccount -> Observable<[DataService.DTO.ExchangeTransaction]> in
                guard let self = self else { return Observable.empty() }

                let query = DataService.Query.ExchangeFilters(matcher: publicKeyAccount.address,
                                                              sender: nil,
                                                              timeStart: nil,
                                                              timeEnd: nil,
                                                              amountAsset: amountAsset,
                                                              priceAsset: priceAsset,
                                                              after: nil,
                                                              limit: limit)

                return self.transactionsDataService.transactionsExchange(query: query)
            }
    }
}
