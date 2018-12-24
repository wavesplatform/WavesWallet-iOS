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
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    func orderBook(amountAsset: String, priceAsset: String) -> Observable<API.DTO.OrderBook> {

        return currentEnvironment().flatMap({ (environment) -> Observable<API.DTO.OrderBook> in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            
            return self.matcherProvider.rx
                .request(.init(kind: .getOrderBook(amountAsset: amountAsset, priceAsset: priceAsset),
                               environment: environment))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(API.DTO.OrderBook.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                .asObservable()
            
        })
    }
    
    func markets(isEnableSpam: Bool) -> Observable<[API.DTO.Market]> {

        return currentEnvironment().flatMap({ (environment) -> Observable<[API.DTO.Market]> in
            
            let markets = self.matcherProvider.rx
                        .request(.init(kind: .getMarket, environment: environment))
                        .filterSuccessfulStatusAndRedirectCodes()
                        .map(API.DTO.MarketResponse.self)
                        .asObservable()
                        .map { $0.markets }
            
            if isEnableSpam {
                return Observable.zip(markets, self.spamList())
                .map({ (markets, spamList) -> [API.DTO.Market] in

                    var filterMarkets: [API.DTO.Market] = []
                    let spamListKeys = spamList.reduce(into:  [String : String](), { $0[$1] = $1})

                    for market in markets {
                        if spamListKeys[market.amountAsset] == nil &&
                            spamListKeys[market.priceAsset] == nil {
                            filterMarkets.append(market)
                        }
                    }

                    return filterMarkets
                })
            }

            return markets
        })
    }
}

private extension DexOrderBookRepositoryRemote {
    
    func spamList() -> Observable<[String]> {
        
        return currentEnvironment().flatMap({ (environment) -> Observable<[String]> in
            
            return self.spamProvider.rx
            .request(.getSpamList(url: environment.servers.spamUrl))
            .filterSuccessfulStatusAndRedirectCodes()
            .asObservable()
            .map({ (response) -> [String] in
                return (try? SpamCVC.addresses(from: response.data)) ?? []
            })
            .catchError({ (error) -> Observable<[String]> in
                return Observable.just([])
            })
        })
    }
    
    func currentEnvironment() -> Observable<Environment> {
        return auth.authorizedWallet().flatMap({ (wallet) -> Observable<Environment> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
        })
    }
}
