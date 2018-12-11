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

private enum Constants {
    static let limit = 100
}

final class DexLastTradesInteractor: DexLastTradesInteractorProtocol {
    
    private let account = FactoryInteractors.instance.accountBalance
    private let lastTradesRepository = FactoryRepositories.instance.lastTradesRespository
    
    var pair: DexTraderContainer.DTO.Pair!

    func displayInfo() -> Observable<(DexLastTrades.DTO.DisplayData)> {

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

private extension DexLastTradesInteractor {
    
    func displayData(lastTrades: [DomainLayer.DTO.DexLastTrade],
                     lastSellBuy: (sell: DexLastTrades.DTO.SellBuyTrade?, buy: DexLastTrades.DTO.SellBuyTrade?),
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
    
    func getLastTrades() -> Observable<[DomainLayer.DTO.DexLastTrade]> {

        return lastTradesRepository.lastTrades(amountAsset: pair.amountAsset,
                                               priceAsset: pair.priceAsset,
                                               limit: Constants.limit)
    }
    
    func getLastSellBuy() -> Observable<(sell: DexLastTrades.DTO.SellBuyTrade?, buy: DexLastTrades.DTO.SellBuyTrade?)> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in
        
            guard let owner = self else { return Disposables.create() }
            
            //TODO: need move to repository
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
