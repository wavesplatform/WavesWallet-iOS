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

private enum Constants {
    static let maxPercent: Float = 99.99
}

final class DexOrderBookInteractor: DexOrderBookInteractorProtocol {
 
    private let account = FactoryInteractors.instance.accountBalance
    private let disposeBag = DisposeBag()
    private let auth = FactoryInteractors.instance.authorization
    private let accountEnvironment = FactoryRepositories.instance.environmentRepository
    private let apiProvider: MoyaProvider<API.Service.Transactions> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    var pair: DexTraderContainer.DTO.Pair!
    
    func displayInfo() -> Observable<(DexOrderBook.DTO.DisplayData)> {

        return Observable.create({ [weak self] (subscribe) -> Disposable in
            
            guard let owner = self else { return Disposables.create() }
            
            let header = DexOrderBook.ViewModel.Header(amountName: owner.pair.amountAsset.name, priceName: owner.pair.priceAsset.name, sumName: owner.pair.priceAsset.name)

            let emptyDisplayData = DexOrderBook.DTO.DisplayData(asks: [],
                                                                lastPrice: DexOrderBook.DTO.LastPrice.empty(decimals: owner.pair.priceAsset.decimals),
                                                                bids: [],
                                                                header: header,
                                                                availablePriceAssetBalance: Money(0 ,owner.pair.priceAsset.decimals),
                                                                availableAmountAssetBalance: Money(0, owner.pair.amountAsset.decimals),
                                                                availableWavesBalance: Money(0, GlobalConstants.WavesDecimals))

            Observable.zip(owner.account.balances(),
                           owner.getLastTransactionInfo())
                .subscribe(onNext: { [weak self] (balances, lastTransaction) in

                    guard let owner = self else { return }

                    //TODO: need move to repository
                    let url = GlobalConstants.Matcher.orderBook(owner.pair.amountAsset.id, owner.pair.priceAsset.id)
                    
                    NetworkManager.getRequestWithUrl(url, parameters: nil, complete: { (info, error) in
                        
                        if let info = info {
                            let displayData = owner.getDisplayData(info: info,
                                                                   lastTransactionInfo: lastTransaction,
                                                                   header: header, balances: balances)
                            subscribe.onNext(displayData)
                        }
                        else {
                            subscribe.onNext(emptyDisplayData)
                        }
                        subscribe.onCompleted()
                    })
                    
                }, onError: { (error) in
                    subscribe.onNext(emptyDisplayData)
                    subscribe.onCompleted()
                }).disposed(by: owner.disposeBag)
            
            return Disposables.create()
        })
    }
    
}

private extension DexOrderBookInteractor {
    
    func getDisplayData(info: JSON, lastTransactionInfo: API.DTO.ExchangeTransaction?, header: DexOrderBook.ViewModel.Header, balances: [DomainLayer.DTO.SmartAssetBalance]) -> DexOrderBook.DTO.DisplayData {
       
        let itemsBids = info["bids"].arrayValue
        let itemsAsks = info["asks"].arrayValue
        
        var bids: [DexOrderBook.DTO.BidAsk] = []
        var asks: [DexOrderBook.DTO.BidAsk] = []

        var totalSumBid: Decimal = 0
        var totalSumAsk: Decimal = 0
        
        let maxAmount = (itemsAsks + itemsBids).map({$0["amount"].int64Value}).max() ?? 0
        let maxAmountValue = Money(maxAmount, pair.amountAsset.decimals).floatValue
        
        for item in itemsBids {

            let price = DexList.DTO.price(amount: item["price"].int64Value, amountDecimals: pair.amountAsset.decimals, priceDecimals: pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
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
            
            let price = DexList.DTO.price(amount: item["price"].int64Value, amountDecimals: pair.amountAsset.decimals, priceDecimals: pair.priceAsset.decimals)
            let amount = Money(item["amount"].int64Value, pair.amountAsset.decimals)
            
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
            
            let type: Dex.DTO.OrderType = tx.orderType == .sell ? .sell : .buy
            
            let price = Money(value: Decimal(tx.price), pair.priceAsset.decimals)
            
            lastPrice = DexOrderBook.DTO.LastPrice(price: price, percent: percent, orderType: type)
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
    
    func getLastTransactionInfo() -> Observable<API.DTO.ExchangeTransaction?> {
        
        //TODO: Need move to repository
        let filters = API.Query.ExchangeFilters(matcher: nil, sender: nil, timeStart: nil, timeEnd: nil,
                                                amountAsset: pair.amountAsset.id,
                                                priceAsset: pair.priceAsset.id,
                                                after: nil,
                                                limit: 1)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso())

        return apiProvider.rx.request(.init(kind: .getExchangeWithFilters(filters), environment: Environments.current),
                                            callbackQueue: DispatchQueue.global(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .asObservable()
            .catchError({ (error) -> Observable<Response> in
                return Observable.error(NetworkError.error(by: error))
            })
            .map(API.Response<[API.Response<API.DTO.ExchangeTransaction>]>.self, atKeyPath: nil, using: decoder, failsOnEmptyData: false)
            .map { $0.data.map { $0.data } }
            .flatMap({ (transactions) -> Observable<API.DTO.ExchangeTransaction?> in
                return Observable.just(transactions.first)
            })
    }
}
