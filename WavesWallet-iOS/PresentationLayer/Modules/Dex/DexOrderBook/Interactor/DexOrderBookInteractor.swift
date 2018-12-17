//
//  DexOrderBookInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import Moya

final class DexOrderBookInteractor: DexOrderBookInteractorProtocol {
 
    private let account = FactoryInteractors.instance.accountBalance
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository
    private let lastTradesRepository = FactoryRepositories.instance.lastTradesRespository
    
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func displayInfo() -> Observable<DexOrderBook.DTO.DisplayData> {

        
            let header = DexOrderBook.ViewModel.Header(amountName: pair.amountAsset.name,
                                                       priceName: pair.priceAsset.name,
                                                       sumName: pair.priceAsset.name)

            let emptyDisplayData = DexOrderBook.DTO.DisplayData(asks: [],
                                                                lastPrice: DexOrderBook.DTO.LastPrice.empty(decimals: pair.priceAsset.decimals),
                                                                bids: [],
                                                                header: header,
                                                                availablePriceAssetBalance: Money(0 ,pair.priceAsset.decimals),
                                                                availableAmountAssetBalance: Money(0, pair.amountAsset.decimals),
                                                                availableWavesBalance: Money(0, GlobalConstants.WavesDecimals))

        
        return Observable.zip(account.balances(),
                              getLastTransactionInfo(),
                              orderBookRepository.orderBook(amountAsset: pair.amountAsset.id, priceAsset: pair.priceAsset.id))
        .flatMap({ [weak self] (balances, lastTransaction, orderBook) -> Observable<DexOrderBook.DTO.DisplayData> in
            guard let owner = self else { return Observable.empty() }
            return Observable.just(owner.getDisplayData(info: orderBook,
                                                        lastTransactionInfo: lastTransaction,
                                                        header: header,
                                                        balances: balances))
        })
        .catchError({ (error) -> Observable<DexOrderBook.DTO.DisplayData> in
            return Observable.just(emptyDisplayData)
        })
    }
}

private extension DexOrderBookInteractor {
    
    func getDisplayData(info: API.DTO.OrderBook, lastTransactionInfo: DomainLayer.DTO.DexLastTrade?, header: DexOrderBook.ViewModel.Header, balances: [DomainLayer.DTO.SmartAssetBalance]) -> DexOrderBook.DTO.DisplayData {
       
        let itemsBids = info.bids
        let itemsAsks = info.asks
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

        var totalSumBid: Decimal = 0
        var totalSumAsk: Decimal = 0
        
        let maxAmount = (itemsAsks + itemsBids).map({$0.amount}).max() ?? 0
        let maxAmountValue = Money(maxAmount, pair.amountAsset.decimals).floatValue
        
        for item in itemsBids {

            let price = DexList.DTO.price(amount: item.price, amountDecimals: pair.amountAsset.decimals, priceDecimals: pair.priceAsset.decimals)
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
            
            let price = DexList.DTO.price(amount: item.price, amountDecimals: pair.amountAsset.decimals, priceDecimals: pair.priceAsset.decimals)
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
                
                percent = ((askValue - bidValue) * 100 / bidValue).floatValue
            }
            
            let type: Dex.DTO.OrderType = tx.type == .sell ? .sell : .buy
            
            lastPrice = DexOrderBook.DTO.LastPrice(price: tx.price, percent: percent, orderType: type)
        }
        
        var amountAssetBalance =  Money(0, pair.amountAsset.decimals)
        var priceAssetBalance =  Money(0, pair.priceAsset.decimals)
        var wavesBalance = Money(0, GlobalConstants.WavesDecimals)
        
        if let amountAsset = balances.first(where: {$0.assetId == pair.amountAsset.id}) {
            amountAssetBalance = Money(amountAsset.avaliableBalance, amountAsset.asset.precision)
        }
        
        if let priceAsset = balances.first(where: {$0.assetId == pair.priceAsset.id}) {
            priceAssetBalance = Money(priceAsset.avaliableBalance, priceAsset.asset.precision)
        }
        
        if let wavesAsset = balances.first(where: {$0.asset.isWaves == true}) {
            wavesBalance = Money(wavesAsset.avaliableBalance, wavesAsset.asset.precision)
        }
        
        return DexOrderBook.DTO.DisplayData(asks: asks.reversed(), lastPrice: lastPrice, bids: bids, header: header,
                                            availablePriceAssetBalance: priceAssetBalance,
                                            availableAmountAssetBalance: amountAssetBalance,
                                            availableWavesBalance: wavesBalance)
    }
    
    func getLastTransactionInfo() -> Observable<DomainLayer.DTO.DexLastTrade?> {
        
        return lastTradesRepository.lastTrades(amountAsset: pair.amountAsset, priceAsset: pair.priceAsset, limit: 1)
            .flatMap({ (lastTrades) ->  Observable<DomainLayer.DTO.DexLastTrade?> in
                return Observable.just(lastTrades.first)
            })
    }
}
