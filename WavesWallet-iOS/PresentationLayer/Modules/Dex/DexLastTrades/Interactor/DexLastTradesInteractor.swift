//
//  DexLastTradesInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import Moya

final class DexLastTradesInteractor: DexLastTradesInteractorProtocol {
    
    private let account = FactoryInteractors.instance.accountBalance
    private let disposeBag = DisposeBag()
    private let apiProvider: MoyaProvider<API.Service.Transactions> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])
    private let accountEnvironment = FactoryRepositories.instance.environmentRepository
    private let auth = FactoryInteractors.instance.authorization
    
    var pair: DexTraderContainer.DTO.Pair!

    func displayInfo() -> Observable<(DexLastTrades.DTO.DisplayData)> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<(DexLastTrades.DTO.DisplayData)>  in
            guard let owner = self else { return Observable.empty() }
            
            return owner.accountEnvironment.accountEnvironment(accountAddress: wallet.address)
                .flatMap({ [weak self] (environment) -> Observable<(DexLastTrades.DTO.DisplayData)> in
                    guard let owner = self else { return Observable.empty() }
                    
                    return Observable.zip(
                    owner.getLastTrades(wallet: wallet.address, environment: environment),
                    owner.getLastSellBuy(),
                    owner.account.balances(isNeedUpdate: false))
                        .flatMap({ [weak self] (lastTrades, lastSellBuy, balances) -> Observable<(DexLastTrades.DTO.DisplayData)> in
                            guard let owner = self else { return Observable.empty() }
                            
                            return owner.displayData(lastTrades: lastTrades,
                                                     lastSellBuy: lastSellBuy,
                                                     balances:  balances)
                        })
                })
        })
        .catchError({ [weak self] (error) -> Observable<(DexLastTrades.DTO.DisplayData)> in
            guard let owner = self else { return Observable.empty() }
            
            let display = DexLastTrades.DTO.DisplayData(trades: [],
                                                        lastSell: nil,
                                                        lastBuy:  nil,
                                                        availableAmountAssetBalance: Money(0, owner.pair.amountAsset.decimals),
                                                        availablePriceAssetBalance: Money(0, owner.pair.priceAsset.decimals),
                                                        availableWavesBalance: Money(0, GlobalConstants.WavesDecimals))
            return Observable.just(display)
        })
    }
}

private extension DexLastTradesInteractor {
    
    func displayData(lastTrades: [DexLastTrades.DTO.Trade],
                     lastSellBuy: (sell: DexLastTrades.DTO.SellBuyTrade?, buy: DexLastTrades.DTO.SellBuyTrade?),
                     balances: [DomainLayer.DTO.AssetBalance]) -> Observable<DexLastTrades.DTO.DisplayData> {
        
        var amountAssetBalance =  Money(0, pair.amountAsset.decimals)
        var priceAssetBalance =  Money(0, pair.priceAsset.decimals)
        var wavesBalance = Money(0, GlobalConstants.WavesDecimals)
        
        if let amountAsset = balances.first(where: {$0.assetId == pair.amountAsset.id}) {
            amountAssetBalance = Money(amountAsset.avaliableBalance, amountAsset.asset?.precision ?? 0)
        }
        
        if let priceAsset = balances.first(where: {$0.assetId == pair.priceAsset.id}) {
            priceAssetBalance = Money(priceAsset.avaliableBalance, priceAsset.asset?.precision ?? 0)
        }
        
        if let wavesAsset = balances.first(where: {$0.asset?.isWaves == true}) {
            wavesBalance = Money(wavesAsset.avaliableBalance, wavesAsset.asset?.precision ?? 0)
        }
        
        let display = DexLastTrades.DTO.DisplayData(trades: lastTrades,
                                                    lastSell: lastSellBuy.sell,
                                                    lastBuy: lastSellBuy.buy,
                                                    availableAmountAssetBalance: amountAssetBalance,
                                                    availablePriceAssetBalance: priceAssetBalance,
                                                    availableWavesBalance: wavesBalance)
        return Observable.just(display)
    }
    
    func getLastTrades(wallet: String, environment: Environment) -> Observable<[DexLastTrades.DTO.Trade]> {

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso())

        let filters = API.Query.ExchangeFilters(matcher: nil, sender: nil, timeStart: nil, timeEnd: nil,
                                                amountAsset: pair.amountAsset.id,
                                                priceAsset: pair.priceAsset.id,
                                                after: nil,
                                                sort: "desc",
                                                limit: 100)
        
        return apiProvider.rx.request(.init(kind: .getExchangeWithFilters(filters), environment: environment),
                                            callbackQueue: DispatchQueue.global(qos: .background))
        .filterSuccessfulStatusAndRedirectCodes()
        .asObservable()
        .catchError({ (error) -> Observable<Response> in
            return Observable.error(NetworkError.error(by: error))
        })
        .map(API.Response<[API.Response<API.DTO.ExchangeTransaction>]>.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
        .map { $0.data.map { $0.data } }
        .flatMap({ [weak self] (transactions) -> Observable<[DexLastTrades.DTO.Trade]> in
            
            guard let owner = self else { return Observable.empty() }
            
            var trades: [DexLastTrades.DTO.Trade] = []
            for tx in transactions {
                
                let sum = Money(value: Decimal(tx.price * tx.amount), owner.pair.priceAsset.decimals)
                let orderType: Dex.DTO.OrderType = tx.orderType == .sell ? .sell : .buy
                
                let model = DexLastTrades.DTO.Trade(time: tx.timestamp,
                                                    price: Money(value: Decimal(tx.price), owner.pair.priceAsset.decimals),
                                                    amount: Money(value: Decimal(tx.amount), owner.pair.amountAsset.decimals),
                                                    sum: sum,
                                                    type: orderType)
                trades.append(model)
            }
            
            return Observable.just(trades)
        })
    }
    
    func getLastSellBuy() -> Observable<(sell: DexLastTrades.DTO.SellBuyTrade?, buy: DexLastTrades.DTO.SellBuyTrade?)> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in
        
            guard let owner = self else { return Disposables.create() }
            
            let url = GlobalConstants.Matcher.orderBook(owner.pair.amountAsset.id, owner.pair.priceAsset.id)
            
            NetworkManager.getRequestWithUrl(url, parameters: nil) { (info, error) in
                
                var sell: DexLastTrades.DTO.SellBuyTrade?
                var buy: DexLastTrades.DTO.SellBuyTrade?
                
                if let info = info {
                    if let bid = info["bids"].arrayValue.first {
                        
                        let price = DexList.DTO.price(amount: bid["price"].int64Value,
                                                      amountDecimals: owner.pair.amountAsset.decimals,
                                                      priceDecimals: owner.pair.priceAsset.decimals)
                        
                        sell = DexLastTrades.DTO.SellBuyTrade(price: price,
                                                              type: .sell)
                    }
                    
                    if let ask = info["asks"].arrayValue.first {
                        
                        let price = DexList.DTO.price(amount: ask["price"].int64Value,
                                                      amountDecimals: owner.pair.amountAsset.decimals,
                                                      priceDecimals: owner.pair.priceAsset.decimals)
                        
                        buy = DexLastTrades.DTO.SellBuyTrade(price: price,
                                                             type: .buy)
                    }
                }

                subscribe.onNext((sell: sell, buy: buy))
                subscribe.onCompleted()
            }
            
            return Disposables.create()
        })
    }
}
