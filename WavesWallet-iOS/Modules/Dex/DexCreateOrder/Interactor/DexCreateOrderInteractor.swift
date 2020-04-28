//
//  DexCreateOrderInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

private enum Constants {
    static let numberForConveringDecimals = 8

    static let rateSmart: Int64 = 400_000
}

final class DexCreateOrderInteractor: DexCreateOrderInteractorProtocol {
    private let auth: AuthorizationUseCaseProtocol
    private let addressRepository: AddressRepositoryProtocol
    private let accountBalance: AccountBalanceUseCaseProtocol
    private let matcherRepository: MatcherRepositoryProtocol
    private let orderBookRepository: DexOrderBookRepositoryProtocol
    private let transactionInteractor: TransactionsUseCaseProtocol
    private let transactionsRepositoryRemote: TransactionsRepositoryProtocol
    private let assetsInteractor: AssetsUseCaseProtocol // какое-то дублирование и размазывание логики, может нам не нужны use case(ы)?
    private let assetsRepository: AssetsRepositoryProtocol
    private let orderBookInteractor: OrderBookUseCaseProtocol
    private let developmentConfig: DevelopmentConfigsRepositoryProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase

    init(authorization: AuthorizationUseCaseProtocol,
         addressRepository: AddressRepositoryProtocol,
         accountBalance: AccountBalanceUseCaseProtocol,
         matcherRepository: MatcherRepositoryProtocol,
         dexOrderBookRepository: DexOrderBookRepositoryProtocol,
         transactionInteractor: TransactionsUseCaseProtocol,
         transactionsRepositoryRemote: TransactionsRepositoryProtocol,
         assetsInteractor: AssetsUseCaseProtocol,
         assetsRepository _: AssetsRepositoryProtocol,
         orderBookInteractor: OrderBookUseCaseProtocol,
         developmentConfig: DevelopmentConfigsRepositoryProtocol,
         serverEnvironmentUseCase: ServerEnvironmentUseCase) {
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
        self.accountBalance = accountBalance
        self.addressRepository = addressRepository
        auth = authorization
        self.matcherRepository = matcherRepository
        orderBookRepository = dexOrderBookRepository
        self.transactionInteractor = transactionInteractor
        self.transactionsRepositoryRemote = transactionsRepositoryRemote
        self.assetsInteractor = assetsInteractor
        self.orderBookInteractor = orderBookInteractor
        self.developmentConfig = developmentConfig
    }

    func getDevConfig() -> Observable<DomainLayer.DTO.DevelopmentConfigs> {
        developmentConfig.developmentConfigs()
    }

    func createOrder(order: DexCreateOrder.DTO.Order,
                     type: DexCreateOrder.DTO.CreateOrderType) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
        calculateMarketOrderPriceIfNeed(order: order, createType: type)
            .flatMap { [weak self] marketOrder -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                guard let self = self else { return Observable.empty() }
                return self.performeCreateOrderRequest(order: order,
                                                       updatedPrice: marketOrder?.price,
                                                       priceAvg: marketOrder?.priceAvg,
                                                       type: type)
            }
            .catchError { error -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
            }
    }

    func getFee(amountAsset: String, priceAsset: String, feeAssetId: String) -> Observable<DexCreateOrder.DTO.FeeSettings> {
        auth.authorizedWallet().flatMap { [weak self] wallet -> Observable<DexCreateOrder.DTO.FeeSettings> in
            guard let self = self else { return Observable.empty() }

            let isSmartAddress = self.serverEnvironmentUseCase.serverEnvironment()
                .flatMap { [weak self] serverEnvironment -> Observable<Bool> in
                    guard let strongSelf = self else { return Observable.never() }
                    return strongSelf.addressRepository.isSmartAddress(serverEnvironment: serverEnvironment,
                                                                       accountAddress: wallet.address)
                }

            // вот тут опять трешак какой-то. это не нормально. нужно избавляться от rx на уровне сети и не плодить больше ничего.
            let isSmartAssets = Observable.combineLatest(
                [amountAsset, priceAsset, feeAssetId]
                    .reduce(into: [Observable<(String, Bool)>]()) { [weak self] result, assetId in

                        guard let strongSelf = self else { return }
                        let isSmartAsset = strongSelf.serverEnvironmentUseCase.serverEnvironment()
                            .flatMap { [weak self] serverEnvironment -> Observable<(String, Bool)> in
                                guard let self = self else { return Observable.never() }

                                return self.assetsRepository
                                    .isSmartAsset(serverEnvironment: serverEnvironment,
                                                  assetId: assetId,
                                                  accountAddress: wallet.address)
                                    .map { isSmartAsset -> (String, Bool) in (assetId, isSmartAsset) }
                            }
                        result.append(isSmartAsset)
                    }
            )

            return Observable.zip(self.orderBookInteractor.orderSettingsFee(),
                                  self.transactionsRepositoryRemote.feeRules(),
                                  isSmartAddress,
                                  self.accountBalance.balances(),
                                  isSmartAssets)
                .flatMap { settingOrderFee, feeRules, isSmartAddress, _, isSmartAssets -> Observable<DexCreateOrder.DTO.FeeSettings> in

                    self.transactionInteractor.calculateFee(by: .createOrder(amountAsset: amountAsset,
                                                                             priceAsset: priceAsset,
                                                                             settingsOrderFee: settingOrderFee,
                                                                             feeAssetId: feeAssetId),
                                                            accountAddress: wallet.address)
                        .map { [weak self] fee in

                            let feeAssets = settingOrderFee.feeAssets.filter { [weak self] feeAsset -> Bool in
                                guard let strongSelf = self else { return false }
                                
                                var isSmartAssetsDict: [String: Bool] = [:]
                                isSmartAssets.forEach { isSmartAssetsDict[$0] = $1 }

                                let allFee = strongSelf.calculateFee(isSmartAddress: isSmartAddress,
                                                                     amountAssetId: amountAsset,
                                                                     priceAssetId: priceAsset,
                                                                     feeAssetId: feeAssetId,
                                                                     asset: feeAsset, // какой ассет сюда передавать?
                                                                     settingOrderFee: feeAsset,
                                                                     baseFee: settingOrderFee.baseFee,
                                                                     rules: feeRules,
                                                                     isSmartAssets: isSmartAssetsDict) // как собирать этот список?

                                // как сравнивать балансы? (откуда брать precision)

                                return true
                                
//                                return assetBalances.first(where: { $0.assetId == feeAsset.asset.id })?
                            }

                            return DexCreateOrder.DTO.FeeSettings(fee: fee, feeAssets: feeAssets)
                        }
                }
        }
    }

    private func calculateFee(isSmartAddress: Bool,
                              amountAssetId: String,
                              priceAssetId: String,
                              feeAssetId: String,
                              asset: DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset,
                              settingOrderFee: DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset,
                              baseFee: Int64,
                              rules: DomainLayer.DTO.TransactionFeeRules,
                              isSmartAssets: [String: Bool]) -> Money {
        let rule = rules.rules[.exchange] ?? rules.defaultRule

        var fee: Int64 = rule.fee

        if rule.addSmartAccountFee, isSmartAddress {
            fee += rules.smartAccountExtraFee
        }

        var n: Int64 = 0

        if isSmartAssets[amountAssetId] == true {
            n += 1
        }

        if isSmartAssets[priceAssetId] == true {
            n += 1
        }

        if isSmartAssets[feeAssetId] == true,
            feeAssetId != amountAssetId,
            feeAssetId != priceAssetId {
            n += 1
        }

        if isSmartAddress {
            n += 1
        }

        let assetDecimal = settingOrderFee.asset.decimals
        let assetFee = settingOrderFee.rate * Double(baseFee + rules.smartAccountExtraFee * n)

        let factorFee = (asset.asset
            .decimals - assetDecimal) // где-то это называется decimals где-то precision. надо описать модели и методы!
        let correctFee: Int64 = {
            let assetFeeDouble = ceil(assetFee)

            if factorFee == 0 {
                return Int64(assetFeeDouble)
            }

            return Int64(ceil(assetFeeDouble / pow(10.0, Double(factorFee))))
        }()

        return Money(correctFee, assetDecimal)
    }

    func isValidOrder(order: DexCreateOrder.DTO.Order) -> Observable<Bool> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

        return Observable.zip(auth.authorizedWallet(), serverEnvironment)
            .flatMap { [weak self] _, serverEnvironment -> Observable<Bool> in

                guard let self = self else { return Observable.empty() }

                return self.orderBookRepository
                    .orderBook(serverEnvironment: serverEnvironment,
                               amountAsset: order.amountAsset.id,
                               priceAsset: order.priceAsset.id)
                    .flatMap { trade -> Observable<Bool> in

                        let price = order.price.decimalValue

                        let isBuy = order.type == .buy

                        let lastPriceTrade = (isBuy == true ? trade.asks.first?.price : trade.bids.first?.price) ?? order.price
                            .amount
                        let lastPrice = Money(lastPriceTrade, order.price.decimals).decimalValue

                        let percent = (price / lastPrice * 100).rounded().int64Value

                        if isBuy {
                            if lastPrice < price, percent >= (100 + UIGlobalConstants.limitPriceOrderPercent) {
                                return Observable.error(DexCreateOrder.CreateOrderError.priceHigherMarket)
                            }
                        } else {
                            if lastPrice > price, percent <= (100 - UIGlobalConstants.limitPriceOrderPercent) {
                                return Observable.error(DexCreateOrder.CreateOrderError.priceLowerMarket)
                            }
                        }

                        return Observable.just(true)
                    }
            }
    }

    func calculateMarketOrderPrice(amountAsset: DomainLayer.DTO.Dex.Asset,
                                   priceAsset: DomainLayer.DTO.Dex.Asset,
                                   orderAmount: Money,
                                   type: DomainLayer.DTO.Dex.OrderType) -> Observable<DexCreateOrder.DTO.MarketOrder> {
        let zeroPriceValue = Money(0, priceAsset.decimals)

        if orderAmount.amount > 0 {
            let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

            return serverEnvironment
                .flatMap { [weak self] serverEnvironment -> Observable<DexCreateOrder.DTO.MarketOrder> in

                    guard let self = self else { return Observable.never() }

                    return self.orderBookRepository
                        .orderBook(serverEnvironment: serverEnvironment,
                                   amountAsset: amountAsset.id,
                                   priceAsset: priceAsset.id)
                        .flatMap { orderBook -> Observable<DexCreateOrder.DTO.MarketOrder> in

                            var filledAmount: Money = Money(0, amountAsset.decimals)
                            var computedTotal: Money = zeroPriceValue
                            var askOrBidPrice: Money = zeroPriceValue

                            let bidOrAsks = type == .buy ? orderBook.asks : orderBook.bids
                            for askOrBid in bidOrAsks {
                                if filledAmount.decimalValue >= orderAmount.decimalValue {
                                    break
                                }

                                askOrBidPrice = Money
                                    .price(amount: askOrBid.price, amountDecimals: amountAsset.decimals,
                                           priceDecimals: priceAsset.decimals)

                                let askOrBidAmount = Money(askOrBid.amount, amountAsset.decimals)
                                let unfilledAmount = Money(value: orderAmount.decimalValue - filledAmount.decimalValue,
                                                           amountAsset.decimals)
                                let amount = unfilledAmount.decimalValue <= askOrBidAmount
                                    .decimalValue ? unfilledAmount : askOrBidAmount
                                let total = askOrBidPrice.decimalValue * amount.decimalValue

                                computedTotal = Money(value: computedTotal.decimalValue + total, computedTotal.decimals)
                                filledAmount = Money(value: filledAmount.decimalValue + amount.decimalValue,
                                                     filledAmount.decimals)
                            }

                            let priceAvg = filledAmount
                                .decimalValue > 0 ? Money(value: computedTotal.decimalValue / filledAmount.decimalValue,
                                                          priceAsset.decimals) : zeroPriceValue
                            return Observable.just(.init(price: askOrBidPrice, priceAvg: priceAvg, total: computedTotal))
                        }
                }
        }

        return Observable.just(.init(price: zeroPriceValue, priceAvg: zeroPriceValue, total: zeroPriceValue))
    }
}

private extension DexCreateOrderInteractor {
    func performeCreateOrderRequest(order: DexCreateOrder.DTO.Order,
                                    updatedPrice: Money?,
                                    priceAvg: Money?,
                                    type: DexCreateOrder.DTO.CreateOrderType)
        -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
        let serverEnvironment = serverEnvironmentUseCase.serverEnvironment()

        return Observable.zip(auth.authorizedWallet(),
                              serverEnvironment)
            .flatMap { [weak self] wallet, serverEnvironment -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in

                guard let self = self else { return Observable.empty() }

                let matcher = self.matcherRepository.matcherPublicKey(serverEnvironment: serverEnvironment)

                return matcher
                    .flatMap { [weak self] matcherPublicKey -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                        guard let self = self else { return Observable.empty() }

                        let precisionDifference = (order.priceAsset.decimals - order.amountAsset.decimals) + Constants
                            .numberForConveringDecimals
                        let orderPrice = updatedPrice ?? order.price
                        let price = (orderPrice.decimalValue * pow(10, precisionDifference)).int64Value

                        let orderQuery = DomainLayer.Query.Dex.CreateOrder(wallet: wallet,
                                                                           matcherPublicKey: matcherPublicKey,
                                                                           amountAsset: order.amountAsset.id,
                                                                           priceAsset: order.priceAsset.id,
                                                                           amount: order.amount.amount,
                                                                           price: price,
                                                                           orderType: order.type,
                                                                           matcherFee: order.fee,
                                                                           timestamp: Date().millisecondsSince1970,
                                                                           expiration: Int64(order.expiration.rawValue),
                                                                           matcherFeeAsset: order.feeAssetId)

                        return self
                            .orderBookRepository
                            .createOrder(serverEnvironment: serverEnvironment,
                                         wallet: wallet,
                                         order: orderQuery,
                                         type: type == .limit ? .limit : .market)
                            .flatMap { _ -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                                let output = DexCreateOrder.DTO.Output(time: Date(milliseconds: orderQuery.timestamp),
                                                                       orderType: order.type,
                                                                       price: priceAvg ?? order.price,
                                                                       amount: order.amount)
                                return Observable.just(ResponseType(output: output, error: nil))
                            }
                    }
            }
    }

    func calculateMarketOrderPriceIfNeed(order: DexCreateOrder.DTO.Order, createType: DexCreateOrder.DTO.CreateOrderType)
        -> Observable<DexCreateOrder.DTO.MarketOrder?> {
        if createType == .market {
            return calculateMarketOrderPrice(amountAsset: order.amountAsset,
                                             priceAsset: order.priceAsset,
                                             orderAmount: order.amount,
                                             type: order.type)
                .map { order -> DexCreateOrder.DTO.MarketOrder? in order }
        } else {
            return Observable.just(nil)
        }
    }
}
