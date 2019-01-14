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
import RealmSwift

final class DexOrderBookRepositoryRemote: DexOrderBookRepositoryProtocol {

    private let matcherProvider: MoyaProvider<Matcher.Service.OrderBook> = .matcherMoyaProvider()
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func orderBook(wallet: DomainLayer.DTO.SignedWallet, amountAsset: String, priceAsset: String) -> Observable<Matcher.DTO.OrderBook> {

        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<Matcher.DTO.OrderBook> in
                guard let owner = self else { return Observable.empty() }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                
                return owner.matcherProvider.rx
                    .request(.init(kind: .getOrderBook(amountAsset: amountAsset, priceAsset: priceAsset),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map(Matcher.DTO.OrderBook.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                    .asObservable()
            
        })
    }
    
    func markets(wallet: DomainLayer.DTO.SignedWallet, isEnableSpam: Bool) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {

        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<[Matcher.DTO.Market]> in
                guard let owner = self else { return Observable.empty() }
                
                let markets = owner.matcherProvider.rx
                            .request(.init(kind: .getMarket, environment: environment),
                                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
                            .filterSuccessfulStatusAndRedirectCodes()
                            .map(Matcher.DTO.MarketResponse.self)
                            .asObservable()
                            .map { $0.markets }
            
                if isEnableSpam {
                    return Observable.zip(markets, owner.spamList(accountAddress: wallet.address))
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
            .map({ [weak self] (markets) -> [DomainLayer.DTO.Dex.SmartPair] in
                guard let owner = self else { return [] }
                
                let realm = try! WalletRealmFactory.realm(accountAddress: wallet.address)
                
                var pairs: [DomainLayer.DTO.Dex.SmartPair] = []
                for market in markets {
                    pairs.append(DomainLayer.DTO.Dex.SmartPair(market, realm: realm))
                }
                pairs = owner.sort(pairs: pairs, realm: realm)
                
                return pairs
            })
    }
    
    
    func myOrders(wallet: DomainLayer.DTO.SignedWallet, amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> {

        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                guard let owner = self else { return Observable.empty() }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970

                return owner.matcherProvider.rx
                .request(.init(kind: .getMyOrders(amountAsset: amountAsset.id,
                                                  priceAsset: priceAsset.id,
                                                  signature: TimestampSignature(signedWallet: wallet)),
                               environment: environment),
                         callbackQueue: DispatchQueue.global(qos: .userInteractive))
                .filterSuccessfulStatusAndRedirectCodes()
                .map([Matcher.DTO.Order].self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
                .asObservable()
                .map({ (orders) -> [DomainLayer.DTO.Dex.MyOrder] in
                    
                    var myOrders: [DomainLayer.DTO.Dex.MyOrder] = []
                    
                    for order in orders {
                        myOrders.append(DomainLayer.DTO.Dex.MyOrder(order,
                                                                    priceAsset: priceAsset,
                                                                    amountAsset: amountAsset))
                        
                    }
                    return myOrders
                })
        })
    }
    
    func cancelOrder(wallet: DomainLayer.DTO.SignedWallet, orderId: String, amountAsset: String, priceAsset: String) -> Observable<Bool> {
        
        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<Bool> in
                guard let owner = self else { return Observable.empty() }
                
                return owner.matcherProvider.rx
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
    }
    
    func createOrder(wallet: DomainLayer.DTO.SignedWallet, order: Matcher.Query.CreateOrder) -> Observable<Bool> {
        
        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<Bool> in

                guard let owner = self else { return Observable.empty() }
                
                return owner.matcherProvider.rx
                    .request(.init(kind: .createOrder(order),
                                   environment: environment),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .asObservable()
                    .map { _ in true }
                
        })
    }
}

//MARK: - SpamList
private extension DexOrderBookRepositoryRemote {
    
    func spamList(accountAddress: String) -> Observable<[String]> {
        
        return environmentRepository.accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<[String]> in
                guard let owner = self else { return Observable.empty() }
                
                return owner.spamProvider.rx
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
}


//MARK: - Markets Sort
private extension DexOrderBookRepositoryRemote {
    
    func sort(pairs: [DomainLayer.DTO.Dex.SmartPair], realm: Realm) -> [DomainLayer.DTO.Dex.SmartPair] {
        
        var sortedPairs: [DomainLayer.DTO.Dex.SmartPair] = []
        
        let generalBalances = realm
            .objects(Asset.self)
            .filter(NSPredicate(format: "isGeneral == true"))
            .toArray()
            .reduce(into: [String: Asset](), { $0[$1.id] = $1 })
        
        let settingsList = realm
            .objects(AssetBalanceSettings.self)
            .toArray()
            .filter { (asset) -> Bool in
                return generalBalances[asset.assetId]?.isGeneral == true
            }
            .sorted(by: { $0.sortLevel < $1.sortLevel })
        
        for settings in settingsList {
            sortedPairs.append(contentsOf: pairs.filter({$0.amountAsset.id == settings.assetId && $0.isGeneral == true }))
        }
        
        var sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { $0.isGeneral == true && !sortedIds.contains($0.id) } )
        
        sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { !sortedIds.contains($0.id) } )
        
        return sortedPairs
    }
}


