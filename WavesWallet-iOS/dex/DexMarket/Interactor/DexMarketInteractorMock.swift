//
//  DexMarketInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON


final class DexMarketInteractorMock: DexMarketInteractorProtocol {
    
    private static var allPairs: [DexMarket.DTO.Pair] = []
    private static var searchPairs: [DexMarket.DTO.Pair] = []
    
    private let searchPairsSubject: PublishSubject<[DexMarket.DTO.Pair]> = PublishSubject<[DexMarket.DTO.Pair]>()

    private let disposeBag: DisposeBag = DisposeBag()
    
    
    func pairs() -> Observable<[DexMarket.DTO.Pair]> {
        return Observable.create({ (subscribe) -> Disposable in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                DexMarketInteractorMock.allPairs = self.getAllPairs()
                subscribe.onNext(DexMarketInteractorMock.allPairs)
            })
            return Disposables.create()
        })
    }
    
    func searchPairs() -> Observable<[DexMarket.DTO.Pair]> {
        return searchPairsSubject.asObserver()
    }
    
    func checkMark(pair: DexMarket.DTO.Pair) {
        
        if let index = DexMarketInteractorMock.searchPairs.index(where: {$0.id == pair.id}) {
            DexMarketInteractorMock.searchPairs[index] = pair.mutate { $0.isChecked = !$0.isChecked }
        }
        
        if let index = DexMarketInteractorMock.allPairs.index(where: {$0.id == pair.id}) {
            DexMarketInteractorMock.allPairs[index] = pair.mutate { $0.isChecked = !$0.isChecked }
        }
    }
    
    func searchPair(searchText: String) {

        DexMarketInteractorMock.searchPairs.removeAll()
        
        if searchText.count > 0 {
            DexMarketInteractorMock.searchPairs = DexMarketInteractorMock.allPairs.filter {
                ($0.name.lowercased() as NSString).range(of: searchText.lowercased()).location != NSNotFound
            }
            searchPairsSubject.onNext(DexMarketInteractorMock.searchPairs)
        }
        else {
            searchPairsSubject.onNext(DexMarketInteractorMock.allPairs)
        }
    }
}

//MARK: - TestData
private extension DexMarketInteractorMock {
    
    func getAllPairs() -> [DexMarket.DTO.Pair] {
        
        var pairs: [DexMarket.DTO.Pair] = []
        let items = parseJSON(json: "DexMarketPairs").arrayValue
        
        for item in items {
            pairs.append(DexMarket.DTO.Pair(id: item["amountAsset"].stringValue + item["priceAsset"].stringValue,                                            
                                            shortName: item["amountAssetName"].stringValue + " / " + item["priceAssetName"].stringValue,
                                            name: item["amountAssetName"].stringValue + " / " + item["priceAssetName"].stringValue,
                                            isChecked: false))
        }
        
        return pairs
    }
    
    func parseJSON(json fileName: String) -> JSON {
        guard let path = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return []
        }
        guard let data = try? Data(contentsOf: path) else {
            return []
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            return []
        }
        
        return JSON(json)
    }
}
