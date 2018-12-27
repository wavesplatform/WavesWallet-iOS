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

    func orderBook(amountAsset: String, priceAsset: String) -> Observable<Matcher.DTO.OrderBook> {

        return currentEnvironment().flatMap({ (environment) -> Observable<Matcher.DTO.OrderBook> in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            
            return self.matcherProvider.rx
                .request(.init(kind: .getOrderBook(amountAsset: amountAsset, priceAsset: priceAsset),
                               environment: environment),
                         callbackQueue: DispatchQueue.global(qos: .userInteractive))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(Matcher.DTO.OrderBook.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                .asObservable()
            
        })
    }
    
    func markets(isEnableSpam: Bool) -> Observable<[Matcher.DTO.Market]> {

        return currentEnvironment().flatMap({ (environment) -> Observable<[Matcher.DTO.Market]> in
            
            let markets = self.matcherProvider.rx
                        .request(.init(kind: .getMarket, environment: environment),
                                 callbackQueue: DispatchQueue.global(qos: .userInteractive))
                        .filterSuccessfulStatusAndRedirectCodes()
                        .map(Matcher.DTO.MarketResponse.self)
                        .asObservable()
                        .map { $0.markets }
            
            if isEnableSpam {
                return Observable.zip(markets, self.spamList())
                .map({ (markets, spamList) -> [Matcher.DTO.Market] in

                    var filterMarkets: [Matcher.DTO.Market] = []
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
    
    
    func myOrders(amountAsset: String, priceAsset: String) -> Observable<[Matcher.DTO.Order]> {

        return self.auth.authorizedWallet().flatMap({ (wallet) -> Observable<[Matcher.DTO.Order]> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ (environment) -> Observable<[Matcher.DTO.Order]> in
                    
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970

                    return self.matcherProvider.rx
                    .request(.init(kind: .getMyOrders(amountAsset: amountAsset,
                                                      priceAsset: priceAsset,
                                                      signature: TimestampSignature(signedWallet: wallet)),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map([Matcher.DTO.Order].self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                    .asObservable()
                })
        })
    }
    
    func cancelOrder(orderId: String, amountAsset: String, priceAsset: String) -> Observable<Bool> {
        
        return self.auth.authorizedWallet().flatMap({ (wallet) -> Observable<Bool> in
            return self.environment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ (environment) -> Observable<Bool> in
                    
                    return self.matcherProvider.rx
                        .request(.init(kind: .cancelOrder(.init(wallet: wallet,
                                                                orderId: orderId,
                                                                amountAsset: amountAsset,
                                                                priceAsset: priceAsset)),
                                       environment: environment),
                                 callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .asObservable()
                    .map { _ in true }
                })
        })
    }
    
    func createOrder(order: Matcher.Query.CreateOrder) -> Observable<Bool> {
        
        return currentEnvironment().flatMap({ (environment) -> Observable<Bool> in
            return self.matcherProvider.rx
                    .request(.init(kind: .createOrder(order),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .asObservable()
                    .map { _ in true }
        })
    }
}

private extension DexOrderBookRepositoryRemote {
    
    func spamList() -> Observable<[String]> {
        
        return currentEnvironment().flatMap({ (environment) -> Observable<[String]> in
            
            return self.spamProvider.rx
            .request(.getSpamList(url: environment.servers.spamUrl),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
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
