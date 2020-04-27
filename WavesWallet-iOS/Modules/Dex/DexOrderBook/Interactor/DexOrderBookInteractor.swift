//
//  DexOrderBookInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import WavesSDK
import DomainLayer
import Extensions

private enum Constants {
    static let maxPercent: Float = 99.99
}

final class DexOrderBookInteractor: DexOrderBookInteractorProtocol {
 
    private let account = UseCasesFactory.instance.accountBalance
    private let orderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
    private let lastTradesRepository = UseCasesFactory.instance.repositories.lastTradesRespository
    private let auth = UseCasesFactory.instance.authorization
    private let assetsInteractor = UseCasesFactory.instance.assets
    private let assetsRepositoryLocal = UseCasesFactory.instance.repositories.assetsRepositoryLocal
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func displayInfo() -> Observable<DexOrderBook.DTO.DisplayData> {

        let header = DexOrderBook.ViewModel.Header(amountName: self.pair.amountAsset.name,
                                                   priceName: self.pair.priceAsset.name,
                                                   sumName: self.pair.priceAsset.name)
        
        let emptyData = DexOrderBook.DTO.Data(asks: [],
                                              lastPrice: self.lastPrice,
                                              bids: [],
                                              header: header,
                                              availablePriceAssetBalance: Money(0, self.pair.priceAsset.decimals),
                                              availableAmountAssetBalance: Money(0, self.pair.amountAsset.decimals),
                                              availableBalances: [],
                                              scriptedAssets: [])
        
        let orderBook = serverEnvironmentUseCase
            .serverEnvironment()
            .flatMap { serverEnvironment -> Observable<DomainLayer.DTO.Dex.OrderBook> in
                return self.orderBookRepository.orderBook(serverEnvironment: serverEnvironment,
                                                          amountAsset: self.pair.amountAsset.id,
                                                          priceAsset: self.pair.priceAsset.id)
            }

        return Observable.zip(self.account.balances(),
                              self.getLastTransactionInfo(),
                              orderBook,
                              self.getScriptedAssets())
            .flatMap({ [weak self] (
                balances,
                lastTransaction,
                orderBook,
                scriptedAssets) -> Observable<DexOrderBook.DTO.DisplayData> in
                
                guard let self = self else { return Observable.empty() }
                return Observable.just(self.getDisplayData(info: orderBook,
                                                           lastTransactionInfo: lastTransaction,
                                                           header: header,
                                                           balances: balances,
                                                           scriptedAssets: scriptedAssets))
            })
            .catchError({ (error) -> Observable<DexOrderBook.DTO.DisplayData> in
                return Observable.just(DexOrderBook.DTO.DisplayData(data: emptyData, authWalletError: false))
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

        var percent: Float = 0
        
        if let ask = asks.first, let bid = bids.first {
            let askValue = ask.price.decimalValue
            let bidValue = bid.price.decimalValue
           
            percent = min(((askValue - bidValue) * 100 / bidValue).floatValue, Constants.maxPercent)
        }
        
        if let tx = lastTransactionInfo {
            let type: DomainLayer.DTO.Dex.OrderType = tx.type == .sell ? .sell : .buy
            lastPrice = DexOrderBook.DTO.LastPrice(price: tx.price, percent: percent, orderType: type)
        }
        else {
            lastPrice.percent = percent
        }
        
        
        var amountAssetBalance =  Money(0, pair.amountAsset.decimals)
        var priceAssetBalance =  Money(0, pair.priceAsset.decimals)
        
        if let amountAsset = balances.first(where: {$0.assetId == pair.amountAsset.id}) {
            amountAssetBalance = Money(amountAsset.availableBalance, amountAsset.asset.precision)
        }
        
        if let priceAsset = balances.first(where: {$0.assetId == pair.priceAsset.id}) {
            priceAssetBalance = Money(priceAsset.availableBalance, priceAsset.asset.precision)
        }
        
        let data = DexOrderBook.DTO.Data(asks: asks.reversed(),
                                         lastPrice: lastPrice,
                                         bids: bids,
                                         header: header,
                                         availablePriceAssetBalance: priceAssetBalance,
                                         availableAmountAssetBalance: amountAssetBalance,
                                         availableBalances: balances,
                                         scriptedAssets: scriptedAssets)
        
        return DexOrderBook.DTO.DisplayData(data: data, authWalletError: false)
    }
    
    func getLastTransactionInfo() -> Observable<DomainLayer.DTO.Dex.LastTrade?> {
        
        let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()
        
        return serverEnviroment
            .flatMap { [weak self] serverEnviroment -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in
                
                guard let self = self else { return Observable.empty() }
                
                return self
                    .lastTradesRepository
                    .lastTrades(serverEnvironment: serverEnviroment,
                                amountAsset: self.pair.amountAsset,
                                priceAsset: self.pair.priceAsset,
                                limit: 1)
        }
        .flatMap({ (lastTrades) ->  Observable<DomainLayer.DTO.Dex.LastTrade?> in
            return Observable.just(lastTrades.first)
        })
    }
    
    func getScriptedAssets() -> Observable<[DomainLayer.DTO.Asset]> {

        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()
        let wallet = auth.authorizedWallet()
        
        return Observable.zip(serverEnvironment, wallet)
            .flatMap({ [weak self] serverEnvironment, wallet -> Observable<[DomainLayer.DTO.Asset]> in
            guard let self = self else { return Observable.empty() }

            let ids = [self.pair.amountAsset.id, self.pair.priceAsset.id]
            
            return self.assetsRepositoryLocal.assets(serverEnvironment: serverEnvironment,
                                                     ids: ids,
                                                     accountAddress: wallet.address)
                .map { $0.filter { $0.hasScript }.sorted(by: { (first, second) -> Bool in
                    return first.id == self.pair.amountAsset.id
                })}
                .catchError({ [weak self] (error) -> Observable<[DomainLayer.DTO.Asset]> in
                    guard let self = self else { return Observable.empty() }

                    return self.assetsInteractor.assets(by: ids, accountAddress: wallet.address)
                })
        })
    }
}
