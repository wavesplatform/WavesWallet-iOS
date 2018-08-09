//
//  DexListInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


fileprivate extension DexList.DTO.Pair {
  
    static func createPair(_ firstPrice: Money, _ lastPrice: Money, _ amountAsset: String, _ amountAssetName: String, _ amountTicker: String, _ amountDecimals: Int, _ priceAsset: String, _ priceAssetName: String, _ priceTicker: String, _ priceDecimals: Int) ->  DexList.DTO.Pair {
        
        return DexList.DTO.Pair(firstPrice: firstPrice, lastPrice: lastPrice, amountAsset: amountAsset, amountAssetName: amountAssetName, amountTicker: amountTicker, amountDecimals: amountDecimals, priceAsset: priceAsset, priceAssetName: priceAssetName, priceTicker: priceTicker, priceDecimals: priceDecimals)
    }
}

final class DexListInteractorMock: DexListInteractorProtocol {
    
    private let refreshPairsSubject: PublishSubject<[DexList.DTO.Pair]> = PublishSubject<[DexList.DTO.Pair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private static var testModels : [DexList.DTO.Pair] = [
        DexList.DTO.Pair.createPair(MoneyUtil.money(123.0), MoneyUtil.money(53.23), "", "WAVES", "WAVES", 8, "", "BTC", "BTC", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(20.0), MoneyUtil.money(43.23), "", "WAVES", "WAVES", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(10.12), MoneyUtil.money(94), "", "Bitcoin", "Bitcoin", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(120), MoneyUtil.money(20.32), "", "ETH Classic", "ETH Classic", 8, "", "IOTA", "IOTA", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(40), MoneyUtil.money(20.32), "", "Monero", "Monero", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(100), MoneyUtil.money(10.4), "", "BTC Cash", "BTC Cash", 8, "", "Waves", "Waves", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(1034.31), MoneyUtil.money(94.00003), "", "ZCash", "ZCash", 8, "", "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(20), MoneyUtil.money(65.000), "", "Bitcoin", "Bitcoin", 8, "", "NEO", "NEO", 8),
        DexList.DTO.Pair.createPair(MoneyUtil.money(200.343), MoneyUtil.money(96.34), "", "NEM", "NEM", 8, "", "BTC", "BTC", 8)]
 
    
    func pairs() -> Observable<[DexList.DTO.Pair]> {
        return Observable.merge(pairs(isNeedUpdate: false), refreshPairsSubject.asObserver())
    }
    
    
    func refreshPairs() {
        
        pairs(isNeedUpdate: true).subscribe(weak: self, onNext: { owner, pairs in
            owner.refreshPairsSubject.onNext(pairs)
        }).disposed(by: disposeBag)
    }
}

private extension DexListInteractorMock {
    
    func pairs(isNeedUpdate: Bool) -> Observable<[DexList.DTO.Pair]> {
        
        if isNeedUpdate {
            var newModels : [DexList.DTO.Pair] = []
            for model in DexListInteractorMock.testModels {
                let newModel = model.mutate {
                    $0.firstPrice = MoneyUtil.money(Double(arc4random() % 200) + Double(arc4random() % 200) * 0.005 + 1)
                    $0.lastPrice = MoneyUtil.money(Double(arc4random() % 200) + Double(arc4random() % 200) * 0.005 + 1)
                }
                newModels.append(newModel)
            }
            DexListInteractorMock.testModels = newModels
        }
        
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                subscribe.onNext(DexListInteractorMock.testModels)
            })
            return Disposables.create()
        })
    }
}

fileprivate extension MoneyUtil {
    
    static func money(_ from: Double) -> Money {
        
        let decimals = getDecimals(from: from)
        let amount = Int64(from * pow(10, decimals).doubleValue)
        return Money(amount, decimals)
    }
    
    private static func getDecimals(from: Double) -> Int {
        
        let number = NSNumber(value: from)
        let resultString = number.stringValue
        
        let theScanner = Scanner(string: resultString)
        let decimalPoint = "."
        var unwanted: NSString?
        
        theScanner.scanUpTo(decimalPoint, into: &unwanted)
        
        if let unwanted = unwanted {
            return ((resultString.count - unwanted.length) > 0) ? resultString.count - unwanted.length - 1 : 0
        }
        return 0
    }
}
