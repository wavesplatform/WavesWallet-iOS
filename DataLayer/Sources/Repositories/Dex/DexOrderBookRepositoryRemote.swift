//
//  DexOrderBookRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import RealmSwift
import WavesSDK
import DomainLayer
import Extensions

private enum Constants {
    static let baseFee: Int64 = 300000
    static let WavesRate: Double = 1
}

final class DexOrderBookRepositoryRemote: DexOrderBookRepositoryProtocol {
        
    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    
    private let spamAssetsRepository: SpamAssetsRepositoryProtocol
    
    private let matcherRepository: MatcherRepositoryProtocol
    
    private let assetsRepository: AssetsRepositoryProtocol
    
    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols,
         spamAssetsRepository: SpamAssetsRepositoryProtocol,
         matcherRepository: MatcherRepositoryProtocol,
         assetsRepository: AssetsRepositoryProtocol) {
        
        self.environmentRepository = environmentRepository
        self.spamAssetsRepository = spamAssetsRepository
        self.matcherRepository = matcherRepository
        self.assetsRepository = assetsRepository
    }
        
    func orderBook(amountAsset: String,
                   priceAsset: String) -> Observable<DomainLayer.DTO.Dex.OrderBook> {

        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ (servicesEnvironment) -> Observable<DomainLayer.DTO.Dex.OrderBook> in
            
                return servicesEnvironment
                    .wavesServices
                    .matcherServices
                    .orderBookMatcherService
                    .orderBook(amountAsset: amountAsset,
                               priceAsset: priceAsset)
                    .flatMap({ (orderBook) -> Observable<DomainLayer.DTO.Dex.OrderBook> in
                        
                        let bids = orderBook.bids.map { DomainLayer.DTO.Dex.OrderBook.Value(amount: $0.amount,
                                                                                            price: $0.price)}
                        
                        let asks = orderBook.asks.map { DomainLayer.DTO.Dex.OrderBook.Value(amount: $0.amount,
                                                                                            price: $0.price)}
                        
                        return Observable.just(DomainLayer.DTO.Dex.OrderBook(bids: bids, asks: asks))
                    })
        })
    }

    func markets(wallet: DomainLayer.DTO.SignedWallet,
                 pairs: [DomainLayer.DTO.Dex.Pair]) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        return Observable.zip(environmentRepository.servicesEnvironment(),
                              matcherRepository.matcherPublicKey())
            .flatMap({ [weak self] (appEnvironment, matcherPublicKey) ->  Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                guard let self = self else { return Observable.empty() }
                
                let queryPairs = pairs.map {DataService.Query.PairsPrice.Pair(amountAssetId: $0.amountAsset.id, priceAssetId: $0.priceAsset.id)}
                return appEnvironment
                        .wavesServices
                        .dataServices
                        .pairsPriceDataService
                    .pairsPrice(query: .init(pairs: queryPairs, matcher: matcherPublicKey.address))
                    .map({ [weak self] (pairsPrice) -> [DomainLayer.DTO.Dex.SmartPair] in
                        
                        guard let self = self, let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address) else {
                            return []
                        }
                        
                        var smartPairs: [DomainLayer.DTO.Dex.SmartPair] = []
                        
                        for (index, pair) in pairsPrice.enumerated() {
                            if pair != nil {
                                let amountAsset = pairs[index].amountAsset
                                let priceAsset = pairs[index].priceAsset
                                smartPairs.append(.init(amountAsset: amountAsset, priceAsset: priceAsset, realm: realm))
                            }
                        }
                        return self.sort(pairs: smartPairs, realm: realm)
                    })

            })
    }
    
    func allMyOrders(wallet: DomainLayer.DTO.SignedWallet) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> {
        return environmentRepository
            .servicesEnvironment()
            .flatMap { (servicesEnvironment) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                
                let signature = TimestampSignature(signedWallet: wallet,
                                                   timestampServerDiff: servicesEnvironment.timestampServerDiff)

                return servicesEnvironment
                    .wavesServices
                    .matcherServices
                    .orderBookMatcherService
                    .allMyOrders(query: .init(publicKey: wallet.publicKey.getPublicKeyStr(),
                                              signature: signature.signature(),
                                              timestamp: signature.timestamp))
                    .flatMap { [weak self] (orders) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                        
                        guard let self = self else { return Observable.empty() }
                        
                        var ids: [String] = []
                        
                        for order in orders {
                            if !ids.contains(order.amountAsset) {
                                ids.append(order.amountAsset)
                            }
                            
                            if !ids.contains(order.priceAsset) {
                                ids.append(order.priceAsset)
                            }
                        }
                        
                        return self.assetsRepository.assets(by: ids, accountAddress: wallet.address)
                            .map { (assets) -> [DomainLayer.DTO.Dex.MyOrder] in

                                var myOrders: [DomainLayer.DTO.Dex.MyOrder] = []
                            
                                for order in orders {
                                    if let amountAsset = assets.first(where: {$0.id == order.amountAsset}),
                                        let priceAsset = assets.first(where: {$0.id == order.priceAsset}) {
                                        
                                        myOrders.append(.init(order,
                                                              priceAsset: .init(id: priceAsset.id,
                                                                                name: priceAsset.displayName,
                                                                                shortName: priceAsset.ticker ?? priceAsset.displayName,
                                                                                decimals: priceAsset.precision),
                                                              
                                                              amountAsset: .init(id: amountAsset.id,
                                                                                 name: amountAsset.displayName,
                                                                                 shortName: amountAsset.ticker ?? amountAsset.displayName,
                                                                                 decimals: amountAsset.precision),
                                                              
                                                              amountAssetIcon: amountAsset.iconLogo,
                                                              priceAssetIcon: priceAsset.iconLogo))
                                    }
                                }
                                
                                return myOrders
                        }
                }
        }
    }
    
    func myOrders(wallet: DomainLayer.DTO.SignedWallet,
                  amountAsset: DomainLayer.DTO.Dex.Asset,
                  priceAsset: DomainLayer.DTO.Dex.Asset) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> {

        return assetsRepository.assets(by: [amountAsset.id, priceAsset.id], accountAddress: wallet.address)
            .flatMap { [weak self] (assets) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                guard let self = self else { return Observable.empty() }
                
                guard let amountAssetIcon = assets.first(where: {$0.id == amountAsset.id})?.iconLogo else { return Observable.empty() }
                guard let priceAssetIcon = assets.first(where: {$0.id == priceAsset.id})?.iconLogo else { return Observable.empty() }
                
                return self.environmentRepository
                        .servicesEnvironment()
                        .flatMapLatest({ (servicesEnvironment) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                               
                            let signature = TimestampSignature(signedWallet: wallet,
                                                              timestampServerDiff: servicesEnvironment.timestampServerDiff)
                           
                           return servicesEnvironment
                               .wavesServices
                               .matcherServices
                               .orderBookMatcherService
                               .myOrders(query: .init(amountAsset: amountAsset.id,
                                                      priceAsset: priceAsset.id,
                                                      publicKey: wallet.publicKey.getPublicKeyStr(),
                                                      signature: signature.signature(),
                                                      timestamp: signature.timestamp))
                           .map({ (orders) -> [DomainLayer.DTO.Dex.MyOrder] in
                               
                               var myOrders: [DomainLayer.DTO.Dex.MyOrder] = []
                               
                               for order in orders {
                                   myOrders.append(DomainLayer.DTO.Dex.MyOrder(order,
                                                                               priceAsset: priceAsset,
                                                                               amountAsset: amountAsset,
                                                                               amountAssetIcon: amountAssetIcon,
                                                                               priceAssetIcon: priceAssetIcon))
                                   
                               }
                               return myOrders
                           })
                       })
            }
    }
    
    func cancelOrder(wallet: DomainLayer.DTO.SignedWallet,
                     orderId: String,
                     amountAsset: String,
                     priceAsset: String) -> Observable<Bool> {
        
        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ (servicesEnvironment) -> Observable<Bool> in
                
                let signature = CancelOrderSignature(signedWallet: wallet, orderId: orderId)
                
                return servicesEnvironment
                    .wavesServices
                    .matcherServices
                    .orderBookMatcherService
                    .cancelOrder(query: .init(orderId: orderId,
                                              amountAsset: amountAsset,
                                              priceAsset: priceAsset,
                                              signature: signature.signature(),
                                              senderPublicKey: wallet.publicKey.getPublicKeyStr()))
            })
    }
    
    func cancelAllOrders(wallet: DomainLayer.DTO.SignedWallet) -> Observable<Bool> {
        return environmentRepository
              .servicesEnvironment()
              .flatMapLatest({ (servicesEnvironment) -> Observable<Bool> in
                  
//                  let signature = CancelAllOrdersSignature(signedWallet: wallet, timestamp: )
                  
                    let signature = TimestampSignature(signedWallet: wallet,
                                                       timestampServerDiff: servicesEnvironment.timestampServerDiff)

                
                  return servicesEnvironment
                      .wavesServices
                      .matcherServices
                      .orderBookMatcherService
                      .cancelAllOrders(query: .init(signature: signature.signature(),
                                                     senderPublicKey: wallet.publicKey.getPublicKeyStr(),
                                                     timestamp: signature.timestamp))
              })
    }
    
    func createOrder(wallet: DomainLayer.DTO.SignedWallet,
                     order: DomainLayer.Query.Dex.CreateOrder,
                     type: DomainLayer.Query.Dex.CreateOrderType) -> Observable<Bool> {
        
        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ (servicesEnvironment) -> Observable<Bool> in
                
                let timestamp = order.timestamp - servicesEnvironment.timestampServerDiff
                
                let expirationTimestamp = timestamp + order.expiration * 60 * 1000
                
                let isWavesFee = order.matcherFeeAsset == WavesSDKConstants.wavesAssetId

                let createOrderSignature = CreateOrderSignature(signedWallet: wallet,
                                                                timestamp: timestamp,
                                                                matcherPublicKey: order.matcherPublicKey,
                                                                assetPair: .init(priceAssetId: order.priceAsset,
                                                                                 amountAssetId: order.amountAsset),
                                                                orderType: (order.orderType == .sell ? .sell : .buy),
                                                                price: order.price,
                                                                amount: order.amount,
                                                                expiration: expirationTimestamp,
                                                                matcherFee: order.matcherFee,
                                                                matcherFeeAsset: order.matcherFeeAsset,
                                                                version: isWavesFee ? .V2 : .V3)
                
                let order = MatcherService.Query.CreateOrder(matcherPublicKey: order.matcherPublicKey.getPublicKeyStr(),
                                                             senderPublicKey: wallet.publicKey.getPublicKeyStr(),
                                                             assetPair: .init(amountAssetId: order.amountAsset, priceAssetId: order.priceAsset),
                                                             amount: order.amount,
                                                             price: order.price,
                                                             orderType: (order.orderType == .sell ? .sell : .buy),
                                                             matcherFee: order.matcherFee,
                                                             timestamp: timestamp,
                                                             expirationTimestamp: expirationTimestamp,
                                                             proofs: [createOrderSignature.signature()],
                                                             matcherFeeAsset: order.matcherFeeAsset)
                
                switch type {
                case .limit:
                    return servicesEnvironment
                            .wavesServices
                            .matcherServices
                            .orderBookMatcherService
                            .createOrder(query: order)
                    
                case .market:
                    return servicesEnvironment
                            .wavesServices
                            .matcherServices
                            .orderBookMatcherService
                            .createMarketOrder(query: order)
                }
        })
    }

    func orderSettingsFee() -> Observable<DomainLayer.DTO.Dex.SettingsOrderFee> {
        
        return environmentRepository
        .servicesEnvironment()
            .flatMap({ (appEnvironment) -> Observable<DomainLayer.DTO.Dex.SettingsOrderFee> in
                return appEnvironment
                    .wavesServices
                    .matcherServices
                    .orderBookMatcherService
                    .settingsRatesFee()
                    .map({ (ratesFee) -> DomainLayer.DTO.Dex.SettingsOrderFee in
                        
                        let assets = ratesFee.map{ DomainLayer.DTO.Dex.SettingsOrderFee.Asset(assetId: $0.assetId, rate: $0.rate) }
                            
                        return DomainLayer.DTO.Dex.SettingsOrderFee(baseFee: Constants.baseFee, feeAssets: assets)
                    })
            })
            .catchError({ (error) -> Observable<DomainLayer.DTO.Dex.SettingsOrderFee> in
                
                //TODO: remove code after MainNet will be support custom fee at matcher
                
                let wavesAsset = DomainLayer.DTO.Dex.SettingsOrderFee.Asset(assetId: WavesSDKConstants.wavesAssetId,
                                                                            rate: Constants.WavesRate)
                let settings = DomainLayer.DTO.Dex.SettingsOrderFee(baseFee: Constants.baseFee, feeAssets: [wavesAsset])
                return Observable.just(settings)
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


private extension MatcherService.DTO.Order {
    var amountAsset: String {
        if let amountAsset = assetPair.amountAsset {
            return amountAsset
        }
        return WavesSDKConstants.wavesAssetId
    }
    
    var priceAsset: String {
        if let priceAsset = assetPair.priceAsset {
            return priceAsset
        }
        return WavesSDKConstants.wavesAssetId
    }
}
