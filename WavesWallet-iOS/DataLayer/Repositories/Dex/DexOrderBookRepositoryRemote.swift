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
import WavesSDK

final class DexOrderBookRepositoryRemote: DexOrderBookRepositoryProtocol {

    private let orderBookMatcherService = ServicesFactory.shared.orderBookMatcherService
    
    private let spamProvider: MoyaProvider<Spam.Service.Assets> = MoyaProvider<Spam.Service.Assets>()
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func orderBook(wallet: DomainLayer.DTO.SignedWallet,
                   amountAsset: String,
                   priceAsset: String) -> Observable<DomainLayer.DTO.Dex.OrderBook> {

        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<DomainLayer.DTO.Dex.OrderBook> in
                guard let self = self else { return Observable.empty() }
                
                return self.orderBookMatcherService
                    .orderBook(amountAsset: amountAsset,
                               priceAsset: priceAsset,
                               enviroment: environment.environmentServiceMatcher)
                    .flatMap({ (orderBook) -> Observable<DomainLayer.DTO.Dex.OrderBook> in
                        
                        let bids = orderBook.bids.map { DomainLayer.DTO.Dex.OrderBook.Value(amount: $0.amount,
                                                                                            price: $0.price)}
                        
                        let asks = orderBook.asks.map { DomainLayer.DTO.Dex.OrderBook.Value(amount: $0.amount,
                                                                                            price: $0.price)}
                        
                        return Observable.just(DomainLayer.DTO.Dex.OrderBook(bids: bids, asks: asks))
                    })
        })
    }
    
    func markets(wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {

        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<[MatcherService.DTO.Market]> in
                guard let self = self else { return Observable.empty() }
                
                let markets = self
                    .orderBookMatcherService
                    .market(enviroment: environment.environmentServiceMatcher)
                    .map { $0.markets }
            
                return Observable.zip(markets, self.spamList(accountAddress: wallet.address))
                    .map({ (markets, spamList) -> [MatcherService.DTO.Market] in

                        var filterMarkets: [MatcherService.DTO.Market] = []
                        let spamListKeys = spamList.reduce(into:  [String : String](), { $0[$1] = $1})

                        for market in markets {
                            if spamListKeys[market.amountAsset] == nil &&
                                spamListKeys[market.priceAsset] == nil {
                                filterMarkets.append(market)
                            }
                        }

                        return filterMarkets
                    })
            })
            .map({ [weak self] (markets) -> [DomainLayer.DTO.Dex.SmartPair] in
                guard let self = self else { return [] }

                //TODO: Remove Realm from remote repository
                guard let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address) else {
                    return []
                }
                
                var pairs: [DomainLayer.DTO.Dex.SmartPair] = []
                for market in markets {
                    pairs.append(DomainLayer.DTO.Dex.SmartPair(market, realm: realm))
                }
                pairs = self.sort(pairs: pairs, realm: realm)
                
                return pairs
            })
    }
    
    
    func myOrders(wallet: DomainLayer.DTO.SignedWallet, amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> {

        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                guard let self = self else { return Observable.empty() }
                
                //TODO: Library
                let signature = TimestampSignature(signedWallet: wallet, environment: environment)
                return self
                    .orderBookMatcherService
                    .myOrders(query: .init(amountAsset: amountAsset.id,
                                           priceAsset: priceAsset.id,
                                           publicKey: wallet.publicKey.getPublicKeyStr(),
                                           signature: signature.signature(),
                                           timestamp: signature.timestamp),
                              enviroment: environment.environmentServiceMatcher)
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
                guard let self = self else { return Observable.empty() }
                
                
                let signature = CancelOrderSignature(signedWallet: wallet, orderId: orderId)
                //TODO: Library
                return self
                    .orderBookMatcherService
                    .cancelOrder(query: .init(orderId: orderId,
                                              amountAsset: amountAsset,
                                              priceAsset: priceAsset,
                                              signature: signature.signature(),
                                              senderPublicKey: wallet.publicKey.getPublicKeyStr()),
                                 enviroment: environment.environmentServiceMatcher)
            })
    }
    
    func createOrder(wallet: DomainLayer.DTO.SignedWallet, order: DomainLayer.Query.Dex.CreateOrder) -> Observable<Bool> {
        
        return environmentRepository.accountEnvironment(accountAddress: wallet.address)
            .flatMap({ [weak self] (environment) -> Observable<Bool> in

                guard let self = self else { return Observable.empty() }
                
                //TODO: Library refactor
                let timestamp = order.timestamp - environment.timestampServerDiff
                
                let expirationTimestamp = timestamp + order.expiration * 60 * 1000
                
                let createOrderSignature = CreateOrderSignature(signedWallet: wallet,
                                                                timestamp: timestamp,
                                                                matcherPublicKey: order.matcherPublicKey,
                                                                assetPair: .init(priceAssetId: order.priceAsset,
                                                                                 amountAssetId: order.amountAsset),
                                                                orderType: (order.orderType == .sell ? .sell : .buy),
                                                                price: order.price,
                                                                amount: order.amount,
                                                                expiration: expirationTimestamp,
                                                                matcherFee: order.matcherFee)
                
                //TODO: Library
                return self
                    .orderBookMatcherService.createOrder(query: .init(matcherPublicKey: order.matcherPublicKey.getPublicKeyStr(),
                                                                      senderPublicKey: wallet.publicKey.getPublicKeyStr(),
                                                                      assetPair: .init(amountAssetId: order.amountAsset, priceAssetId: order.priceAsset),
                                                                      amount: order.amount,
                                                                      price: order.price,
                                                                      orderType: (order.orderType == .sell ? .sell : .buy),
                                                                      matcherFee: order.matcherFee,
                                                                      timestamp: timestamp,
                                                                      expirationTimestamp: expirationTimestamp,
                                                                      proofs: [createOrderSignature.signature()]),
                                                         enviroment: environment.environmentServiceMatcher)
        })
    }
}

//MARK: - SpamList
private extension DexOrderBookRepositoryRemote {
    
    func spamList(accountAddress: String) -> Observable<[String]> {
        
        return environmentRepository.accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                
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


