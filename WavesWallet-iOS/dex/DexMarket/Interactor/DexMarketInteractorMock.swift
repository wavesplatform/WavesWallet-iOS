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
        
        if let index = DexMarketInteractorMock.searchPairs.index(where: {$0.amountAsset == pair.amountAsset && $0.priceAsset == pair.priceAsset}) {
            DexMarketInteractorMock.searchPairs[index] = pair.mutate { $0.isChecked = !$0.isChecked }
        }
        
        if let index = DexMarketInteractorMock.allPairs.index(where: {$0.amountAsset == pair.amountAsset && $0.priceAsset == pair.priceAsset}) {
            DexMarketInteractorMock.allPairs[index] = pair.mutate { $0.isChecked = !$0.isChecked }
        }
    }
    
    func searchPair(searchText: String) {

        DexMarketInteractorMock.searchPairs.removeAll()
        
        if searchText.count > 0 {
            
            DexMarketInteractorMock.searchPairs = DexMarketInteractorMock.allPairs.filter {
                searchPair(amountAssetName: $0.amountAsset.name, priceAssetName: $0.priceAsset.name, searchText: searchText)
            }
            
            searchPairsSubject.onNext(DexMarketInteractorMock.searchPairs)
        }
        else {
            searchPairsSubject.onNext(DexMarketInteractorMock.allPairs)
        }
    }
}

private extension DexMarketInteractorMock {

    func searchPair(amountAssetName: String, priceAssetName: String, searchText: String) -> Bool {
       
        let searchWords = searchText.components(separatedBy: " ").filter {$0.count > 0}

        var isFind = false
        let separator = "/"
        let containSeparator = searchWords.contains(separator)
        
        if searchWords.count == 3 && containSeparator {
            isFind = isValidSearch(inputText: amountAssetName, searchText: searchWords[0]) &&
                isValidSearch(inputText: priceAssetName, searchText: searchWords[2])
        }
        else if searchWords.count == 2 {
            if searchWords[1] == separator {
                isFind = isValidSearch(inputText: amountAssetName, searchText: searchWords[0])
            }
            else {
                isFind = isValidSearch(inputText: amountAssetName, searchText: searchWords[0]) &&
                    isValidSearch(inputText: priceAssetName, searchText: searchWords[1])
            }
        }
        else {
            for word in searchWords {
                isFind = isValidSearch(inputText: amountAssetName, searchText: word) ||
                    isValidSearch(inputText: priceAssetName, searchText: word)
            }
        }
        return isFind
    }
    
    func isValidSearch(inputText: String, searchText: String) -> Bool {
        return (inputText.lowercased() as NSString).range(of: searchText.lowercased()).location != NSNotFound
    }
}

//MARK: - TestData
private extension DexMarketInteractorMock {
    
    func getAllPairs() -> [DexMarket.DTO.Pair] {
        
        var pairs: [DexMarket.DTO.Pair] = []
        let items = parseJSON(json: "DexMarketPairs").arrayValue
        
        for item in items {
            
            let amountAsset = DexMarket.DTO.Asset(id: item["amountAsset"].stringValue,
                                                 name: item["amountAssetName"].stringValue,
                                                 shortName: item["amountAssetName"].stringValue)

            let priceAsset = DexMarket.DTO.Asset(id: item["priceAsset"].stringValue,
                                                 name: item["priceAssetName"].stringValue,
                                                 shortName: item["priceAssetName"].stringValue)

            pairs.append(DexMarket.DTO.Pair(amountAsset: amountAsset, priceAsset: priceAsset, isChecked: false, isHiddenPair: false))
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
