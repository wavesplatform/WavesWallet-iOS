//
//  DexOrderBookInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

private enum Constants {
    static let maxPercent: Float = 99.99
}

final class DexOrderBookInteractor: DexOrderBookInteractorProtocol {
 
    private let account = FactoryInteractors.instance.accountBalance
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository
    private let lastTradesRepository = FactoryRepositories.instance.lastTradesRespository
    private let auth = FactoryInteractors.instance.authorization
    private let assetsInteractor = FactoryInteractors.instance.assetsInteractor
    private let assetsRepositoryLocal = FactoryRepositories.instance.assetsRepositoryLocal
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func displayInfo() -> Observable<DexOrderBook.DTO.DisplayData> {

        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<DexOrderBook.DTO.DisplayData> in
            guard let owner = self else { return Observable.empty() }
            
            let header = DexOrderBook.ViewModel.Header(amountName: owner.pair.amountAsset.name,
                                                       priceName: owner.pair.priceAsset.name,
                                                       sumName: owner.pair.priceAsset.name)
            
            let emptyDisplayData = DexOrderBook.DTO.DisplayData(asks: [],
                                                                lastPrice: owner.lastPrice,
                                                                bids: [],
                                                                header: header,
                                                                availablePriceAssetBalance: Money(0, owner.pair.priceAsset.decimals),
                                                                availableAmountAssetBalance: Money(0, owner.pair.amountAsset.decimals),
                                                                availableWavesBalance: Money(0, GlobalConstants.WavesDecimals),
                                                                scriptedAssets: [])
            return Observable.zip(owner.account.balances(),
                                  owner.getLastTransactionInfo(),
                                  owner.orderBookRepository.orderBook(wallet: wallet,
                                                                      amountAsset: owner.pair.amountAsset.id,
                                                                      priceAsset: owner.pair.priceAsset.id),
                                  owner.getScriptedAssets())
                .flatMap({ [weak self] (
                    balances,
                    lastTransaction,
                    orderBook,
                    scriptedAssets) -> Observable<DexOrderBook.DTO.DisplayData> in
                    
                    guard let owner = self else { return Observable.empty() }
                    return Observable.just(owner.getDisplayData(info: orderBook,
                                                                lastTransactionInfo: lastTransaction,
                                                                header: header,
                                                                balances: balances,
                                                                scriptedAssets: scriptedAssets))
                })
                .catchError({ (error) -> Observable<DexOrderBook.DTO.DisplayData> in
                    return Observable.just(emptyDisplayData)
                })
        })
    }
}

private extension DexOrderBookInteractor {
    
    var lastPrice: DexOrderBook.DTO.LastPrice {
        return DexOrderBook.DTO.LastPrice.empty(decimals: pair.priceAsset.decimals)
    }
    
    func getDisplayData(info: DomainLayer.DTO.Dex.OrderBook,
                        lastTransactionInfo: DomainLayer.DTO.Dex.LastTrade?,
                        header: DexOrderBook.ViewModel.Header,
                        balances: [DomainLayer.DTO.SmartAssetBalance],
                        scriptedAssets: [DomainLayer.DTO.Asset]) -> DexOrderBook.DTO.DisplayData {
       
        let itemsBids = info.bids
        let itemsAsks = info.asks
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

        var totalSumBid: Decimal = 0
        var totalSumAsk: Decimal = 0
        
        let maxAmount = (itemsAsks + itemsBids).map({$0.amount}).max() ?? 0
        let maxAmountValue = Money(maxAmount, pair.amountAsset.decimals).floatValue
        
        for item in itemsBids {

            let price = Money.price(amount: item.price, amountDecimals: pair.amountAsset.decimals, priceDecimals: pair.priceAsset.decimals)
            let amount = Money(item.amount, pair.amountAsset.decimals)
            
            totalSumBid += price.decimalValue * amount.decimalValue
            
            let percent: Float = 100 * amount.floatValue / maxAmountValue

            let bid = DexOrderBook.DTO.BidAsk(price: price,
                                              amount: amount,
                                              sum: Money(value: totalSumBid, price.decimals),
                                              orderType: .sell,
                                              percentAmount: percent)
            bids.append(bid)
        }
        
        for item in itemsAsks {
            
            let price = Money.price(amount: item.price, amountDecimals: pair.amountAsset.decimals, priceDecimals: pair.priceAsset.decimals)
            let amount = Money(item.amount, pair.amountAsset.decimals)
            
            totalSumAsk += price.decimalValue * amount.decimalValue

            let percent: Float = 100 * amount.floatValue / maxAmountValue

            let ask = DexOrderBook.DTO.BidAsk(price: price,
                                              amount: amount,
                                              sum: Money(value: totalSumAsk, price.decimals),
                                              orderType: .buy,
                                              percentAmount: percent)
            asks.append(ask)
        }
        
        
        var lastPrice = DexOrderBook.DTO.LastPrice.empty(decimals: pair.priceAsset.decimals)

        if let tx = lastTransactionInfo {
            var percent: Float = 0
            if let ask = asks.first, let bid = bids.first {
                let askValue = ask.price.decimalValue
                let bidValue = bid.price.decimalValue
                
                percent = min(((askValue - bidValue) * 100 / bidValue).floatValue, Constants.maxPercent) 
            }
            
            let type: DomainLayer.DTO.Dex.OrderType = tx.type == .sell ? .sell : .buy
            
            lastPrice = DexOrderBook.DTO.LastPrice(price: tx.price, percent: percent, orderType: type)
        }
        
        var amountAssetBalance =  Money(0, pair.amountAsset.decimals)
        var priceAssetBalance =  Money(0, pair.priceAsset.decimals)
        var wavesBalance = Money(0, GlobalConstants.WavesDecimals)
        
        if let amountAsset = balances.first(where: {$0.assetId == pair.amountAsset.id}) {
            amountAssetBalance = Money(amountAsset.availableBalance, amountAsset.asset.precision)
        }
        
        if let priceAsset = balances.first(where: {$0.assetId == pair.priceAsset.id}) {
            priceAssetBalance = Money(priceAsset.availableBalance, priceAsset.asset.precision)
        }
        
        if let wavesAsset = balances.first(where: {$0.asset.isWaves == true}) {
            wavesBalance = Money(wavesAsset.availableBalance, wavesAsset.asset.precision)
        }
        
        return DexOrderBook.DTO.DisplayData(asks: asks.reversed(), lastPrice: lastPrice, bids: bids, header: header,
                                            availablePriceAssetBalance: priceAssetBalance,
                                            availableAmountAssetBalance: amountAssetBalance,
                                            availableWavesBalance: wavesBalance,
                                            scriptedAssets: scriptedAssets)
    }
    
    func getLastTransactionInfo() -> Observable<DomainLayer.DTO.Dex.LastTrade?> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<DomainLayer.DTO.Dex.LastTrade?> in
            guard let owner = self else { return Observable.empty() }
            return owner.lastTradesRepository.lastTrades(accountAddress: wallet.address,
                                                         amountAsset: owner.pair.amountAsset,
                                                         priceAsset: owner.pair.priceAsset,
                                                         limit: 1)
                .flatMap({ (lastTrades) ->  Observable<DomainLayer.DTO.Dex.LastTrade?> in
                    return Observable.just(lastTrades.first)
                })
        })
    }
    
    func getScriptedAssets() -> Observable<[DomainLayer.DTO.Asset]> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Asset]> in
            guard let owner = self else { return Observable.empty() }

            let ids = [owner.pair.amountAsset.id, owner.pair.priceAsset.id]
            return owner.assetsRepositoryLocal.assets(by: ids, accountAddress: wallet.address)
                .map { $0.filter { $0.hasScript }.sorted(by: { (first, second) -> Bool in
                    return first.id == owner.pair.amountAsset.id
                })}
                .catchError({ [weak self] (error) -> Observable<[DomainLayer.DTO.Asset]> in
                    guard let owner = self else { return Observable.empty() }

                    return owner.assetsInteractor.assets(by: ids, accountAddress: wallet.address)
                })
        })
    }
}
