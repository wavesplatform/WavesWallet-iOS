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
  
    static func createPair(_ firstPrice: Money, _ lastPrice: Money, _ amountAsset: String, _ amountAssetName: String, _ amountDecimals: Int, _ priceAsset: String, _ priceAssetName: String, _ priceDecimals: Int) ->  DexList.DTO.Pair {
        
        let amountAsset = Dex.DTO.Asset(id: amountAsset, name: amountAssetName, decimals: amountDecimals)
        let priceAsset = Dex.DTO.Asset(id: priceAsset, name: priceAssetName, decimals: priceDecimals)
        
        let isFiat = DexList.DTO.fiatAssets.contains(amountAsset.id) ||  DexList.DTO.fiatAssets.contains(priceAsset.id)
        return DexList.DTO.Pair(firstPrice: firstPrice, lastPrice: lastPrice, amountAsset: amountAsset, priceAsset: priceAsset, isHidden: false)
    }
}

final class DexListInteractorMock: DexListInteractorProtocol {
    
    private let refreshPairsSubject: PublishSubject<[DexList.DTO.Pair]> = PublishSubject<[DexList.DTO.Pair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private static var testModels : [DexList.DTO.Pair] = [

        DexList.DTO.Pair.createPair(Money(value: 123.0, 8), Money(value: 53.234234234234, 8), "WAVES", "WAVES", 8,
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8),
        
        DexList.DTO.Pair.createPair(Money(value: 314.0, 8), Money(value: 350.0, 8), "WAVES", "WAVES", 8,
                                    "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 2),
        
        DexList.DTO.Pair.createPair(Money(value: 20.0, 8), Money(value: 43.2300, 8), "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8,
                                    "WAVES", "WAVES", 8),
        
        DexList.DTO.Pair.createPair(Money(value: 10.12, 8), Money(value: 44543.9442342348374823748830004234, 8),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8),
        
        DexList.DTO.Pair.createPair(Money(value: 120.0, 8), Money(value: 434.15, 8),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 2),        
        
        DexList.DTO.Pair.createPair(Money(value: 20.0, 8), Money(value: 43.2300, 8),
                                    "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8,
                                    "WAVES", "WAVES",  8),
        DexList.DTO.Pair.createPair(Money(value: 10.12, 8), Money(value: 44543.9442342348374823748830004234, 8),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8),
        
        DexList.DTO.Pair.createPair(Money(value: 120.0, 8), Money(value: 434.15, 8),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 8),
        
        DexList.DTO.Pair.createPair(Money(value: 120.0, 8), Money(value: 20.32423423423, 8), "ETH Classic", "ETH Classic", 8,
                                    "IOTA", "IOTA", 8),
        
        DexList.DTO.Pair.createPair(Money(value: 40.0, 8), Money(value: 20.32, 8), "Monero", "Monero", 8,
                                    "ETH", "ETH", 8),
        
        DexList.DTO.Pair.createPair(Money(value: 100.0, 8), Money(value: 10.4, 8), "BTC Cash", "BTC Cash", 8,
                                    "Waves", "Waves", 8),
        DexList.DTO.Pair.createPair(Money(value: 1034.31, 8), Money(value: 94.00003, 8), "ZCash", "ZCash", 8,
                                    "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(Money(value: 20.0, 8), Money(value: 65.000, 8), "Bitcoin", "Bitcoin", 8,
                                    "NEO", "NEO", 8),
        DexList.DTO.Pair.createPair(Money(value: 200.343, 8), Money(value: 96.34, 8), "NEM", "NEM", 8,
                                    "BTC", "BTC", 8)]
 
    
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
                    $0.firstPrice = Money(value: Decimal(arc4random() % 200) + Decimal(arc4random() % 200) * 0.005 + 1, $0.firstPrice.decimals)
                    $0.lastPrice = Money(value: Decimal(arc4random() % 200) + Decimal(arc4random() % 200) * 0.005 + 1, $0.firstPrice.decimals)
                }
                newModels.append(newModel)
            }
            DexListInteractorMock.testModels = newModels
        }
        
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                subscribe.onNext(DexListInteractorMock.testModels)
            })
            return Disposables.create()
        })
    }
}
