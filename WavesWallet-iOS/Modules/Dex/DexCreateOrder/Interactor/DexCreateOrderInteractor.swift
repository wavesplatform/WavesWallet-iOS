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
    private let assetsRepository: AssetsRepositoryProtocol
    private let orderBookInteractor: OrderBookUseCaseProtocol
    private let developmentConfig: DevelopmentConfigsRepositoryProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase
    private let assetsInteractors: AssetsUseCaseProtocol

    init(authorization: AuthorizationUseCaseProtocol,
         addressRepository: AddressRepositoryProtocol,
         accountBalance: AccountBalanceUseCaseProtocol,
         matcherRepository: MatcherRepositoryProtocol,
         dexOrderBookRepository: DexOrderBookRepositoryProtocol,
         transactionInteractor: TransactionsUseCaseProtocol,
         transactionsRepositoryRemote: TransactionsRepositoryProtocol,
         assetsRepository: AssetsRepositoryProtocol,
         orderBookInteractor: OrderBookUseCaseProtocol,
         developmentConfig: DevelopmentConfigsRepositoryProtocol,
         serverEnvironmentUseCase: ServerEnvironmentUseCase,
         assetsInteractors: AssetsUseCaseProtocol) {
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
        self.accountBalance = accountBalance
        self.addressRepository = addressRepository
        auth = authorization
        self.matcherRepository = matcherRepository
        orderBookRepository = dexOrderBookRepository
        self.assetsRepository = assetsRepository
        self.transactionInteractor = transactionInteractor
        self.transactionsRepositoryRemote = transactionsRepositoryRemote
        self.orderBookInteractor = orderBookInteractor
        self.developmentConfig = developmentConfig
        self.assetsInteractors = assetsInteractors
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

    func getFee(amountAsset: String,
                priceAsset: String,
                selectedFeeAssetId: String) -> Observable<DexCreateOrder.DTO.FeeSettings> {
        auth.authorizedWallet().flatMap { [weak self] wallet -> Observable<DexCreateOrder.DTO.FeeSettings> in
            guard let strongSelf = self else { return Observable.empty() }

            let isSmartAddress = strongSelf.isSmartAddress(walletAddress: wallet.address)

            let isSmartAssets = strongSelf.isSmartAssets([amountAsset, priceAsset, selectedFeeAssetId],
                                                         walletAddress: wallet.address)

            return Observable.zip(strongSelf.orderBookInteractor.orderSettingsFee(),
                                  strongSelf.transactionsRepositoryRemote.feeRules(),
                                  isSmartAddress,
                                  strongSelf.accountBalance.balances(),
                                  isSmartAssets,
                                  strongSelf.obtainWavesAsset(accountAddress: wallet.address))
                .flatMap { [weak self]
                    settingOrderFee, feeRules, isSmartAddress, availableAccountBalances, isSmartAssets, wavesAsset
                    -> Observable<DexCreateOrder.DTO.FeeSettings> in
                    guard let strongSelf = self else { return Observable.never() }

                    let transactionSpecs = DomainLayer.Query.TransactionSpecificationType.createOrder(
                        amountAsset: amountAsset,
                        priceAsset: priceAsset,
                        settingsOrderFee: settingOrderFee,
                        feeAssetId: selectedFeeAssetId)

                    return strongSelf.transactionInteractor
                        .calculateFee(by: transactionSpecs, accountAddress: wallet.address)
                        .map { [weak self] fee in
                            let filteredFeeAssets = settingOrderFee.feeAssets.filter { [weak self] feeAsset -> Bool in
                                guard let strongSelf = self else { return false }
                                return strongSelf.filterFeeAssets(feeAsset: feeAsset,
                                                                  wavesAsset: wavesAsset,
                                                                  isSmartAssets: isSmartAssets,
                                                                  isSmartAddress: isSmartAddress,
                                                                  amountAsset: amountAsset,
                                                                  priceAsset: priceAsset,
                                                                  selectedFeeAssetId: selectedFeeAssetId,
                                                                  baseFee: settingOrderFee.baseFee,
                                                                  feeRules: feeRules,
                                                                  availableAccountBalances: availableAccountBalances)
                            }

                            return DexCreateOrder.DTO.FeeSettings(fee: fee, feeAssets: filteredFeeAssets)
                        }
                }
        }
    }

    private func filterFeeAssets(feeAsset: DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset,
                                 wavesAsset: DomainLayer.DTO.Asset,
                                 isSmartAssets: [(String, Bool)],
                                 isSmartAddress: Bool,
                                 amountAsset: String,
                                 priceAsset: String,
                                 selectedFeeAssetId: String,
                                 baseFee: Int64,
                                 feeRules: DomainLayer.DTO.TransactionFeeRules,
                                 availableAccountBalances: [DomainLayer.DTO.SmartAssetBalance]) -> Bool {
        // не проверяем количество waves отображаем его всегда в списке
        if feeAsset.asset.id == WavesSDKConstants.wavesAssetId {
            return true
        }

        var isSmartAssetsDict: [String: Bool] = [:]
        isSmartAssets.forEach { isSmartAssetsDict[$0] = $1 }

        // конечная комиссия для конкретного ассета
        let finalFee = calculateFee(isSmartAddress: isSmartAddress,
                                    amountAssetId: amountAsset,
                                    priceAssetId: priceAsset,
                                    feeAssetId: selectedFeeAssetId,
                                    asset: wavesAsset,
                                    settingOrderFee: feeAsset,
                                    baseFee: baseFee,
                                    rules: feeRules,
                                    isSmartAssets: isSmartAssetsDict)

        let availableAssetBalance = availableAccountBalances.first(where: { $0.assetId == feeAsset.asset.id })
        let assetBalanceMoney = Money(availableAssetBalance?.availableBalance ?? 0, availableAssetBalance?.asset.precision ?? 0)

        // конечная комиссия должна быть меньше чем баланс на счету
        return finalFee < assetBalanceMoney
    }

    private func calculateFee(isSmartAddress: Bool,
                              amountAssetId: String,
                              priceAssetId: String,
                              feeAssetId: String,
                              asset: DomainLayer.DTO.Asset,
                              settingOrderFee: DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset,
                              baseFee: Int64,
                              rules: DomainLayer.DTO.TransactionFeeRules,
                              isSmartAssets: [String: Bool]) -> Money {
        let rule = rules.rules[.exchange] ?? rules.defaultRule

        var fee: Int64 = rule.fee

        if rule.addSmartAccountFee, isSmartAddress {
            fee += rules.smartAccountExtraFee
        }

        var extraFeeMultiplier: Int64 = 0

        if isSmartAssets[amountAssetId] == true {
            extraFeeMultiplier += 1
        }

        if isSmartAssets[priceAssetId] == true {
            extraFeeMultiplier += 1
        }

        if isSmartAssets[feeAssetId] == true, feeAssetId != amountAssetId, feeAssetId != priceAssetId {
            extraFeeMultiplier += 1
        }

        if isSmartAddress {
            extraFeeMultiplier += 1
        }

        let assetDecimal = settingOrderFee.asset.decimals
        let assetFee = settingOrderFee.rate * Double(baseFee + rules.smartAccountExtraFee * extraFeeMultiplier)

        let factorFee = (asset.precision - assetDecimal)
        let correctFee: Int64 = {
            let assetFeeDouble = ceil(assetFee)

            if factorFee == 0 {
                return Int64(assetFeeDouble)
            }

            return Int64(ceil(assetFeeDouble / pow(10.0, Double(factorFee))))
        }()

        return Money(correctFee, assetDecimal)
    }

    private func isSmartAddress(walletAddress: String) -> Observable<Bool> {
        serverEnvironmentUseCase
            .serverEnvironment()
            .flatMap { [weak self] serverEnvironment -> Observable<Bool> in
                guard let strongSelf = self else { return Observable.never() }
                return strongSelf.addressRepository.isSmartAddress(serverEnvironment: serverEnvironment,
                                                                   accountAddress: walletAddress)
            }
    }

    private func isSmartAssets(_ assets: [String], walletAddress: String) -> Observable<[(String, Bool)]> {
        Observable.combineLatest(
            assets.reduce(into: [Observable<(String, Bool)>]()) { [weak self] result, assetId in
                guard let strongSelf = self else { return }
                let isSmartAsset = strongSelf.serverEnvironmentUseCase.serverEnvironment()
                    .flatMap { [weak self] serverEnvironment -> Observable<(String, Bool)> in
                        guard let self = self else { return Observable.never() }

                        return self.assetsRepository
                            .isSmartAsset(serverEnvironment: serverEnvironment,
                                          assetId: assetId,
                                          accountAddress: walletAddress)
                            .map { isSmartAsset -> (String, Bool) in (assetId, isSmartAsset) }
                    }

                result.append(isSmartAsset)
            }
        )
    }
    
    private func obtainWavesAsset(accountAddress: String) -> Observable<DomainLayer.DTO.Asset> {
        assetsInteractors.assetsSync(by: [WavesSDKConstants.wavesAssetId], accountAddress: accountAddress)
            .flatMap { asset -> Observable<DomainLayer.DTO.Asset> in
                if let result = asset.remote?.first {
                    return Observable.just(result)
                } else if let result = asset.local?.result.first {
                    return Observable.just(result)
                } else if let error = asset.error {
                    return Observable.error(error)
                } else {
                    return Observable.error(TransactionsUseCaseError.invalid)
                }
        }
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
