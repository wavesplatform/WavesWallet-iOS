//
//  DexCreateOrderInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import WavesSDK
import Extensions
import DomainLayer

private enum Constants {
    static let numberForConveringDecimals = 8
}

final class DexCreateOrderInteractor: DexCreateOrderInteractorProtocol {
    
    private let auth = UseCasesFactory.instance.authorization
    private let matcherRepository = UseCasesFactory.instance.repositories.matcherRepository
    private let orderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
    private let transactionInteractor = UseCasesFactory.instance.transactions
    private let assetsInteractor = UseCasesFactory.instance.assets
    private let orderBookInteractor = UseCasesFactory.instance.oderbook
    private let environmentRepository = UseCasesFactory.instance.repositories.environmentRepository
    
  
    func createOrder(order: DexCreateOrder.DTO.Order, type: DexCreateOrder.DTO.CreateOrderType) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
        
        return calculateMarketOrderPriceIfNeed(order: order, createType: type)
            .flatMap { [weak self] marketOrder -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                guard let self = self else { return Observable.empty() }
                return self.performeCreateOrderRequest(order: order, updatedPrice: marketOrder?.price, priceAvg: marketOrder?.priceAvg, type: type)
        }
        .catchError { error -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
        }
    }
    
    func getFee(amountAsset: String, priceAsset: String, feeAssetId: String) -> Observable<DexCreateOrder.DTO.FeeSettings> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<DexCreateOrder.DTO.FeeSettings>  in
            guard let self = self else { return Observable.empty() }
            
            return self.orderBookInteractor.orderSettingsFee()
                .flatMap({ [weak self] (smartSettings) -> Observable<DexCreateOrder.DTO.FeeSettings> in
                    
                    guard let self = self else { return Observable.empty() }
                                                                      
                    return self.transactionInteractor.calculateFee(by: .createOrder(amountAsset: amountAsset,
                                                                                    priceAsset: priceAsset,
                                                                                    settingsOrderFee: smartSettings,
                                                                                    feeAssetId: feeAssetId),
                                                                   accountAddress: wallet.address)
                        .map({ (fee) -> DexCreateOrder.DTO.FeeSettings in
                            return DexCreateOrder.DTO.FeeSettings(fee: fee, feeAssets: smartSettings.feeAssets)
                        })
                })
        })
    }
    
    func isValidOrder(order: DexCreateOrder.DTO.Order) -> Observable<Bool> {
        
        return auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Bool> in
            
                guard let self = self else { return Observable.empty() }
                
                return self.orderBookRepository.orderBook(amountAsset: order.amountAsset.id,
                                                          priceAsset: order.priceAsset.id)
                    .flatMap({ (trade) -> Observable<Bool> in
                                                
                        let price = order.price.decimalValue
                        
                        let isBuy = order.type == .buy
                        
                        let lastPriceTrade = (isBuy == true ? trade.asks.first?.price : trade.bids.first?.price) ?? order.price.amount
                        let lastPrice = Money(lastPriceTrade, order.price.decimals).decimalValue
                        
                        let percent = (price / lastPrice * 100).rounded().int64Value
                                                
                        if isBuy {
                            if lastPrice < price && percent >= (100 + UIGlobalConstants.limitPriceOrderPercent) {
                                return Observable.error(DexCreateOrder.CreateOrderError.priceHigherMarket)
                            }
                        } else {
                            if lastPrice > price && percent <= (100 - UIGlobalConstants.limitPriceOrderPercent) {
                                return Observable.error(DexCreateOrder.CreateOrderError.priceLowerMarket)
                            }
                        }
                        
                        return Observable.just(true)
                    })
            })
        }
    
    
    func calculateMarketOrderPrice(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, orderAmount: Money, type: DomainLayer.DTO.Dex.OrderType) -> Observable<DexCreateOrder.DTO.MarketOrder> {
     
        let zeroPriceValue = Money(0, priceAsset.decimals)
        
        if orderAmount.amount > 0 {
            return orderBookRepository.orderBook(amountAsset: amountAsset.id, priceAsset: priceAsset.id)
                .flatMap { orderBook -> Observable<DexCreateOrder.DTO.MarketOrder> in
  
                    var filledAmount: Money = Money(0, amountAsset.decimals)
                    var computedTotal: Money = zeroPriceValue
                    var askOrBidPrice: Money = zeroPriceValue

                    let bidOrAsks = type == .buy ? orderBook.asks : orderBook.bids
                    for askOrBid in bidOrAsks {
                        if filledAmount.decimalValue >= orderAmount.decimalValue {
                            break
                        }

                        askOrBidPrice = Money.price(amount: askOrBid.price, amountDecimals: amountAsset.decimals, priceDecimals: priceAsset.decimals)

                        let askOrBidAmount = Money(askOrBid.amount, amountAsset.decimals)
                        let unfilledAmount = Money(value: orderAmount.decimalValue - filledAmount.decimalValue, amountAsset.decimals)
                        let amount = unfilledAmount.decimalValue <= askOrBidAmount.decimalValue ? unfilledAmount : askOrBidAmount
                        let total = askOrBidPrice.decimalValue * amount.decimalValue

                        computedTotal = Money(value: computedTotal.decimalValue + total, computedTotal.decimals)
                        filledAmount = Money(value: filledAmount.decimalValue + amount.decimalValue, filledAmount.decimals)
                    }

                    let priceAvg = filledAmount.decimalValue > 0 ? Money(value: computedTotal.decimalValue / filledAmount.decimalValue, priceAsset.decimals) : zeroPriceValue
                    return Observable.just(.init(price: askOrBidPrice, priceAvg: priceAvg, total: computedTotal))
            }
        }
        
        return Observable.just(.init(price: zeroPriceValue, priceAvg: zeroPriceValue, total: zeroPriceValue))
    }
}

private extension DexCreateOrderInteractor {

    func performeCreateOrderRequest(order: DexCreateOrder.DTO.Order, updatedPrice: Money?, priceAvg: Money?, type: DexCreateOrder.DTO.CreateOrderType) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> {
        
        return auth.authorizedWallet()
               .flatMap{ [weak self] wallet -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
               
               guard let self = self else { return Observable.empty() }
               
               let matcher = self.matcherRepository.matcherPublicKey()
               let environment = self.environmentRepository.applicationEnvironment()
               
               //TODO: Code move to another method
               return Observable.zip(matcher, environment)
                   .flatMap{ [weak self] (matcherPublicKey, environment) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                       guard let self = self else { return Observable.empty() }
                       
                    
                       let precisionDifference =  (order.priceAsset.decimals - order.amountAsset.decimals) + Constants.numberForConveringDecimals
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
                           .createOrder(wallet: wallet, order: orderQuery, type: type == .limit ? .limit : .market)
                           .flatMap({ (success) -> Observable<ResponseType<DexCreateOrder.DTO.Output>> in
                               let output = DexCreateOrder.DTO.Output(time: Date(milliseconds: orderQuery.timestamp),
                                                                      orderType: order.type,
                                                                      price: priceAvg ?? order.price,
                                                                      amount: order.amount)
                               return Observable.just(ResponseType(output: output, error: nil))
                           })
                   }
           }
    }
    
    func calculateMarketOrderPriceIfNeed(order: DexCreateOrder.DTO.Order, createType: DexCreateOrder.DTO.CreateOrderType) -> Observable<DexCreateOrder.DTO.MarketOrder?> {
        
        if createType == .market {
            return calculateMarketOrderPrice(amountAsset: order.amountAsset,
                                             priceAsset: order.priceAsset,
                                             orderAmount: order.amount,
                                             type: order.type)
                .map { (order) -> DexCreateOrder.DTO.MarketOrder? in
                    return order
            }
        }
        return Observable.just(nil)
    }
}
