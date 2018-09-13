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
        return DexList.DTO.Pair(firstPrice: firstPrice, lastPrice: lastPrice, amountAsset: amountAsset, priceAsset: priceAsset, isHidden: false, isFiat: isFiat)
    }
}

final class DexListInteractorMock: DexListInteractorProtocol {
    
    private let refreshPairsSubject: PublishSubject<[DexList.DTO.Pair]> = PublishSubject<[DexList.DTO.Pair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private static var testModels : [DexList.DTO.Pair] = [

        DexList.DTO.Pair.createPair(Money(123.0), Money(53.234234234234), "WAVES", "WAVES", 8,
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8),
        
        DexList.DTO.Pair.createPair(Money(314), Money(350), "WAVES", "WAVES", 8,
                                    "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 2),
        
        DexList.DTO.Pair.createPair(Money(20.0), Money(43.2300), "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8,
                                    "WAVES", "WAVES", 8),
        
        DexList.DTO.Pair.createPair(Money(10.12), Money(44543.9442342348374823748830004234),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8),
        
        DexList.DTO.Pair.createPair(Money(120.0), Money(434.15),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 2),        
        
        DexList.DTO.Pair.createPair(Money(20.0), Money(43.2300),
                                    "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8,
                                    "WAVES", "WAVES",  8),
        DexList.DTO.Pair.createPair(Money(10.12), Money(44543.9442342348374823748830004234),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu", "ETH", 8),
        
        DexList.DTO.Pair.createPair(Money(120.0), Money(434.15),
                                    "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS", "BTC", 8,
                                    "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck", "USD", 8),
        
        DexList.DTO.Pair.createPair(Money(120), Money(20.32423423423424235453643), "ETH Classic", "ETH Classic", 8,
                                    "IOTA", "IOTA", 8),
        
        DexList.DTO.Pair.createPair(Money(40), Money(20.32), "Monero", "Monero", 8,
                                    "ETH", "ETH", 8),
        
        DexList.DTO.Pair.createPair(Money(100), Money(10.4), "BTC Cash", "BTC Cash", 8,
                                    "Waves", "Waves", 8),
        DexList.DTO.Pair.createPair(Money(1034.31), Money(94.00003), "ZCash", "ZCash", 8,
                                    "ETH", "ETH", 8),
        DexList.DTO.Pair.createPair(Money(20), Money(65.000), "Bitcoin", "Bitcoin", 8,
                                    "NEO", "NEO", 8),
        DexList.DTO.Pair.createPair(Money(200.343), Money(96.34), "NEM", "NEM", 8,
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
                    $0.firstPrice = Money(Double(arc4random() % 200) + Double(arc4random() % 200) * 0.005 + 1)
                    $0.lastPrice = Money(Double(arc4random() % 200) + Double(arc4random() % 200) * 0.005 + 1)
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
