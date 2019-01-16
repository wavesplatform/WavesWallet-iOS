//
//  DexLastTradesInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

private enum Constants {
    static let limit = 100
}

final class DexLastTradesInteractor: DexLastTradesInteractorProtocol {

    private struct LastSellBuy {
        let sell: DexLastTrades.DTO.SellBuyTrade?
        let buy: DexLastTrades.DTO.SellBuyTrade?
    }
    
    private let account = FactoryInteractors.instance.accountBalance
    private let lastTradesRepository = FactoryRepositories.instance.lastTradesRespository
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository
    private let auth = FactoryInteractors.instance.authorization
    
    var pair: DexTraderContainer.DTO.Pair!

    func displayInfo() -> Observable<DexLastTrades.DTO.DisplayData> {

        return Observable.zip(getLastTrades(), getLastSellBuy(), account.balances())
            .flatMap({ [weak self] (lastTrades, lastSellBuy, balances) -> Observable<(DexLastTrades.DTO.DisplayData)> in
                guard let owner = self else { return Observable.empty() }
                
                return owner.displayData(lastTrades: lastTrades,
                                         lastSellBuy: lastSellBuy,
                                         balances:  balances)
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


extension DexLastTradesInteractor {
    
    private func displayData(lastTrades: [DomainLayer.DTO.Dex.LastTrade],
                             lastSellBuy: LastSellBuy,
                             balances: [DomainLayer.DTO.SmartAssetBalance]) -> Observable<DexLastTrades.DTO.DisplayData> {
        
        var amountAssetBalance =  Money(0, pair.amountAsset.decimals)
        var priceAssetBalance =  Money(0, pair.priceAsset.decimals)
        var wavesBalance = Money(0, GlobalConstants.WavesDecimals)
        
        if let amountAsset = balances.first(where: {$0.assetId == pair.amountAsset.id}) {
            amountAssetBalance = Money(amountAsset.avaliableBalance, amountAsset.asset.precision)
        }
        
        if let priceAsset = balances.first(where: {$0.assetId == pair.priceAsset.id}) {
            priceAssetBalance = Money(priceAsset.avaliableBalance, priceAsset.asset.precision)
        }
        
        if let wavesAsset = balances.first(where: { $0.asset.isWaves == true }) {
            wavesBalance = Money(wavesAsset.avaliableBalance, wavesAsset.asset.precision)
        }
        
        let display = DexLastTrades.DTO.DisplayData(trades: lastTrades,
                                                    lastSell: lastSellBuy.sell,
                                                    lastBuy: lastSellBuy.buy,
                                                    availableAmountAssetBalance: amountAssetBalance,
                                                    availablePriceAssetBalance: priceAssetBalance,
                                                    availableWavesBalance: wavesBalance)
        return Observable.just(display)
    }
    
    private func getLastTrades() -> Observable<[DomainLayer.DTO.Dex.LastTrade]> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in
            guard let owner = self else { return Observable.empty() }
            return owner.lastTradesRepository.lastTrades(accountAddress: wallet.address,
                                                         amountAsset: owner.pair.amountAsset,
                                                         priceAsset: owner.pair.priceAsset,
                                                         limit: Constants.limit)
        })
      
    }
    
    private func getLastSellBuy() -> Observable<LastSellBuy> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<LastSellBuy> in
            guard let owner = self else { return Observable.empty() }


            return owner.orderBookRepository.orderBook(wallet: wallet,
                                                       amountAsset: owner.pair.amountAsset.id,
                                                       priceAsset: owner.pair.priceAsset.id)
                .flatMap({ [weak self] (orderbook) -> Observable<LastSellBuy> in
                    
                    guard let owner = self else { return Observable.empty() }
                    
                    var sell: DexLastTrades.DTO.SellBuyTrade?
                    var buy: DexLastTrades.DTO.SellBuyTrade?
                    
                    if let bid = orderbook.bids.first {
                        
                        let price = Money.price(amount: bid.price,
                                                      amountDecimals: owner.pair.amountAsset.decimals,
                                                      priceDecimals: owner.pair.priceAsset.decimals)
                        
                        sell = DexLastTrades.DTO.SellBuyTrade(price: price, type: .sell)
                    }
                    
                    if let ask = orderbook.asks.first {
                        
                        let price = Money.price(amount: ask.price,
                                                      amountDecimals: owner.pair.amountAsset.decimals,
                                                      priceDecimals: owner.pair.priceAsset.decimals)
                        
                        buy = DexLastTrades.DTO.SellBuyTrade(price: price, type: .buy)
                    }
                    
                    return Observable.just(LastSellBuy(sell: sell, buy: buy))
                })
        })
        
    }
}
