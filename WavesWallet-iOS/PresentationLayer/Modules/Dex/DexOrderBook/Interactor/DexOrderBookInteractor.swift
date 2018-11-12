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

final class DexOrderBookInteractor: DexOrderBookInteractorProtocol {
 
    private let account = FactoryInteractors.instance.accountBalance
    private let disposeBag = DisposeBag()
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func displayInfo() -> Observable<(DexOrderBook.DTO.DisplayData)> {

        return Observable.create({ [weak self] (subscribe) -> Disposable in
            
            guard let owner = self else { return Disposables.create() }
            
            //TODO: need change api to get only balances by ids
            owner.account.balances(isNeedUpdate: false).subscribe(onNext: { [weak self] (balances) in
                
                guard let owner = self else { return }

                let header = DexOrderBook.ViewModel.Header(amountName: owner.pair.amountAsset.name, priceName: owner.pair.priceAsset.name, sumName: owner.pair.priceAsset.name)

                //TODO: need change to Observer network
                let url = GlobalConstants.Matcher.orderBook(owner.pair.amountAsset.id, owner.pair.priceAsset.id)
                
                NetworkManager.getRequestWithUrl(url, parameters: nil, complete: { (info, error) in
                    
                    if let info = info {
                        owner.getLastPriceInfo({ (lastPriceInfo) in
                            subscribe.onNext(owner.getDisplayData(info: info, lastPriceInfo: lastPriceInfo, header: header, balances: balances))
                        })
                    }
                    else {
                        subscribe.onNext(DexOrderBook.DTO.DisplayData(asks: [], lastPrice: DexOrderBook.DTO.LastPrice.empty(decimals: owner.pair.priceAsset.decimals), bids: [],
                                                                      header: header,
                                                                      availablePriceAssetBalance: Money(0 ,owner.pair.priceAsset.decimals),
                                                                      availableAmountAssetBalance: Money(0, owner.pair.amountAsset.decimals),
                                                                      availableWavesBalance: Money(0, GlobalConstants.WavesDecimals)))
                    }
                })
                
            }).disposed(by: owner.disposeBag)
         
            return Disposables.create()
        })
    }
    
}

private extension DexOrderBookInteractor {
    
    func getDisplayData(info: JSON, lastPriceInfo: JSON?, header: DexOrderBook.ViewModel.Header, balances: [DomainLayer.DTO.AssetBalance]) -> DexOrderBook.DTO.DisplayData {
       
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

        if let priceInfo = lastPriceInfo {
            var percent: Float = 0
            if let ask = asks.first, let bid = bids.first {
                let askValue = ask.price.decimalValue
                let bidValue = bid.price.decimalValue
                
                percent = ((askValue - bidValue) * 100 / bidValue).floatValue
            }
            
            let type = priceInfo["type"].stringValue == "buy" ? Dex.DTO.OrderType.buy :  Dex.DTO.OrderType.sell
            let price = Money(value: Decimal(priceInfo["price"].doubleValue), pair.priceAsset.decimals)
            
            lastPrice = DexOrderBook.DTO.LastPrice(price: price, percent: percent, orderType: type)
        }
        
        var amountAssetBalance =  Money(0, pair.amountAsset.decimals)
        var priceAssetBalance =  Money(0, pair.priceAsset.decimals)
        var wavesBalance = Money(0, GlobalConstants.WavesDecimals)
        
        if let amountAsset = balances.first(where: {$0.assetId == pair.amountAsset.id}) {
            amountAssetBalance = Money(amountAsset.avaliableBalance, amountAsset.asset?.precision ?? 0)
        }
        
        if let priceAsset = balances.first(where: {$0.assetId == pair.priceAsset.id}) {
            priceAssetBalance = Money(priceAsset.avaliableBalance, priceAsset.asset?.precision ?? 0)
        }
        
        if let wavesAsset = balances.first(where: {$0.asset?.isWaves == true}) {
            wavesBalance = Money(wavesAsset.avaliableBalance, wavesAsset.asset?.precision ?? 0)
        }
        
        return DexOrderBook.DTO.DisplayData(asks: asks.reversed(), lastPrice: lastPrice, bids: bids, header: header,
                                            availablePriceAssetBalance: priceAssetBalance,
                                            availableAmountAssetBalance: amountAssetBalance,
                                            availableWavesBalance: wavesBalance)
    }
    
    func getLastPriceInfo(_ complete:@escaping(_ lastPriceInfo: JSON?) -> Void) {
        
        let url = GlobalConstants.Market.trades(pair.amountAsset.id, pair.priceAsset.id, 1)
            
        //TODO: need change to Observer network
        NetworkManager.getRequestWithUrl(url, parameters: nil) { (info, error) in
            complete(info?.array?.first)
        }
    }
}
