//
//  DexOrderBookRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

final class DexOrderBookRepositoryRemote: DexOrderBookRepositoryProtocol {

    private let matcherProvider: MoyaProvider<Matcher.Service.OrderBook> = .matcherMoyaProvider()
    private let environment = FactoryRepositories.instance.environmentRepository
    private let auth = FactoryInteractors.instance.authorization
    
    func orderBook(amountAsset: String, priceAsset: String) -> Observable<API.DTO.OrderBook> {

        return auth.authorizedWallet().flatMap({ (wallet) -> Observable<API.DTO.OrderBook> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ (environment) -> Observable<API.DTO.OrderBook> in
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970

                    return self.matcherProvider.rx
                    .request(.init(kind: .getOrderBook(amountAsset: amountAsset, priceAsset: priceAsset),
                            environment: environment), callbackQueue: DispatchQueue.global(qos: .background))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(API.DTO.OrderBook.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                    .asObservable()
                })
        })
    }
}
