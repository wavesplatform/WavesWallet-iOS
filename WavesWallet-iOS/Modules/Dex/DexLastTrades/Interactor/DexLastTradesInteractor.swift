//
//  DexLastTradesInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK

private enum Constants {
    static let limit = 100
}

final class DexLastTradesInteractor: DexLastTradesInteractorProtocol {
    private struct LastSellBuy {
        let sell: DexLastTrades.DTO.SellBuyTrade?
        let buy: DexLastTrades.DTO.SellBuyTrade?
    }

    private let account = UseCasesFactory.instance.accountBalance
    private let lastTradesRepository = UseCasesFactory.instance.repositories.lastTradesRespository
    private let orderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
    private let auth = UseCasesFactory.instance.authorization
    private let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository
    private let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

    var pair: DexTraderContainer.DTO.Pair!

    func displayInfo() -> Observable<DexLastTrades.DTO.DisplayData> {
        Observable.zip(getLastTrades(),
                       getLastSellBuy(),
                       account.balances(),
                       getScriptedAssets())
            .flatMap { [weak self] (lastTrades, lastSellBuy, balances, scriptedAssets) -> Observable<DexLastTrades.DTO.DisplayData> in
                guard let self = self else { return Observable.empty() }

                return self.displayData(lastTrades: lastTrades,
                                        lastSellBuy: lastSellBuy,
                                        balances: balances,
                                        scriptedAssets: scriptedAssets)
            }
            .catchError { [weak self] (_) -> Observable<DexLastTrades.DTO.DisplayData> in
                guard let self = self else { return Observable.empty() }

                let display = DexLastTrades.DTO.DisplayData(trades: [],
                                                            lastSell: nil,
                                                            lastBuy: nil,
                                                            availableAmountAssetBalance: Money(0, self.pair.amountAsset.decimals),
                                                            availablePriceAssetBalance: Money(0, self.pair.priceAsset.decimals),
                                                            availableBalances: [],
                                                            scriptedAssets: [])
                return Observable.just(display)
            }
    }
}

extension DexLastTradesInteractor {
    private func displayData(lastTrades: [DomainLayer.DTO.Dex.LastTrade],
                             lastSellBuy: LastSellBuy,
                             balances: [DomainLayer.DTO.SmartAssetBalance],
                             scriptedAssets: [Asset]) -> Observable<DexLastTrades.DTO.DisplayData> {
        var amountAssetBalance = Money(0, pair.amountAsset.decimals)
        var priceAssetBalance = Money(0, pair.priceAsset.decimals)

        if let amountAsset = balances.first(where: { $0.assetId == pair.amountAsset.id }) {
            amountAssetBalance = Money(amountAsset.availableBalance, amountAsset.asset.precision)
        }

        if let priceAsset = balances.first(where: { $0.assetId == pair.priceAsset.id }) {
            priceAssetBalance = Money(priceAsset.availableBalance, priceAsset.asset.precision)
        }

        let display = DexLastTrades.DTO.DisplayData(trades: lastTrades,
                                                    lastSell: lastSellBuy.sell,
                                                    lastBuy: lastSellBuy.buy,
                                                    availableAmountAssetBalance: amountAssetBalance,
                                                    availablePriceAssetBalance: priceAssetBalance,
                                                    availableBalances: balances,
                                                    scriptedAssets: scriptedAssets)
        return Observable.just(display)
    }

    private func getLastTrades() -> Observable<[DomainLayer.DTO.Dex.LastTrade]> {
        return serverEnvironmentUseCase
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Dex.LastTrade]> in

                guard let self = self else { return Observable.never() }

                return self.lastTradesRepository
                    .lastTrades(serverEnvironment: serverEnvironment,
                                amountAsset: self.pair.amountAsset,
                                priceAsset: self.pair.priceAsset,
                                limit: Constants.limit)
            }
    }

    private func getLastSellBuy() -> Observable<LastSellBuy> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

        let orderBook = serverEnvironment
            .flatMap { [weak self] serverEnvironment -> Observable<DomainLayer.DTO.Dex.OrderBook> in

                guard let self = self else { return Observable.never() }

                return self.orderBookRepository
                    .orderBook(serverEnvironment: serverEnvironment,
                               amountAsset: self.pair.amountAsset.id,
                               priceAsset: self.pair.priceAsset.id)
            }

        return orderBook
            .flatMap { [weak self] (orderbook) -> Observable<LastSellBuy> in

                guard let self = self else { return Observable.empty() }

                var sell: DexLastTrades.DTO.SellBuyTrade?
                var buy: DexLastTrades.DTO.SellBuyTrade?

                if let bid = orderbook.bids.first {
                    let price = Money.price(amount: bid.price,
                                            amountDecimals: self.pair.amountAsset.decimals,
                                            priceDecimals: self.pair.priceAsset.decimals)

                    sell = DexLastTrades.DTO.SellBuyTrade(price: price, type: .sell)
                }

                if let ask = orderbook.asks.first {
                    let price = Money.price(amount: ask.price,
                                            amountDecimals: self.pair.amountAsset.decimals,
                                            priceDecimals: self.pair.priceAsset.decimals)

                    buy = DexLastTrades.DTO.SellBuyTrade(price: price, type: .buy)
                }

                return Observable.just(LastSellBuy(sell: sell, buy: buy))
            }
    }

    func getScriptedAssets() -> Observable<[Asset]> {
        let serverEnviroment = serverEnvironmentUseCase.serverEnvironment()
        let wallet = auth.authorizedWallet()

        return Observable.zip(wallet, serverEnviroment)
            .flatMap { [weak self] wallet, _ -> Observable<[Asset]> in
                guard let self = self else { return Observable.empty() }

                let ids = [self.pair.amountAsset.id, self.pair.priceAsset.id]
                return self.assetsRepository.assets(ids: ids,
                                                    accountAddress: wallet.address)
                    .map { $0.compactMap { $0 }}
                    .map { $0.filter { $0.hasScript }.sorted(by: { (first, _) -> Bool in
                        first.id == self.pair.amountAsset.id
                    }) }
            }
    }
}
