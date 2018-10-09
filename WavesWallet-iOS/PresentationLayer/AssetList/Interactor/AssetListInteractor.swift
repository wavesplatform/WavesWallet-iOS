//
//  AssetListInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class AssetListInteractor: AssetListInteractorProtocol {
    
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    
    private let searchString: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
    private var _assets: [DomainLayer.DTO.AssetBalance] = []

    func assets(filters: [AssetList.DTO.Filter]) -> Observable<[DomainLayer.DTO.AssetBalance]> {
        
        let assets = accountBalanceInteractor.balances(isNeedUpdate: false)
        
        let merge = Observable.merge([assets]).map { [weak self] assets -> [DomainLayer.DTO.AssetBalance] in
            
            if filters.contains(.all) {
                self?._assets = assets
            }
            else {
                self?.filterAssets(filters: filters, assets: assets)
            }
            return self?._assets ?? []
        }
      
        let search = searchString
            .asObserver().skip(1)
            .map { [weak self] searchString -> [DomainLayer.DTO.AssetBalance] in
                return self?._assets ?? []
        }
        
        return Observable
            .merge([merge, search])
            .map { [weak self] assets -> [DomainLayer.DTO.AssetBalance] in
                
                let searchText = (try? self?.searchString.value() ?? "") ?? ""
                
                let newAssets = assets.filter {
                    guard let asset = $0.asset else { return false }
                    return self?.isValidSearch(name: asset.displayName, searchText: searchText) ?? false
                }
                return newAssets
        }
        
    }
    
    func searchAssets(searchText: String) {
        searchString.onNext(searchText)
    }
}


private extension AssetListInteractor {
    
    func filterAssets(filters: [AssetList.DTO.Filter], assets: [DomainLayer.DTO.AssetBalance]) {
        
        var filterAssets: [DomainLayer.DTO.AssetBalance] = []
                
        if filters.contains(.waves) {
            
            filterAssets.append(contentsOf: assets.filter({
                guard let asset = $0.asset else { return false }
                
                return asset.isFiat == false &&
                    asset.isWavesToken == false &&
                    asset.isGateway == false &&
                    asset.isWaves == true}))
        }
        
        if filters.contains(.cryptoCurrency) {
            
                filterAssets.append(contentsOf: assets.filter({
                    guard let asset = $0.asset else { return false }
                    
                    return asset.isFiat == false &&
                        asset.isWavesToken == false &&
                        asset.isGateway == true &&
                        asset.isWaves == false}))
        }
        
        if filters.contains(.fiat) {
            
                filterAssets.append(contentsOf: assets.filter({
                    guard let asset = $0.asset else { return false }
                    
                    return asset.isFiat == true &&
                        asset.isWavesToken == false &&
                        asset.isGateway == true &&
                        asset.isWaves == false}))
        }
        
        if filters.contains(.wavesToken) {
            
                filterAssets.append(contentsOf: assets.filter({
                    guard let asset = $0.asset else { return false }
                    
                    return asset.isFiat == false &&
                        asset.isWavesToken == true &&
                        asset.isGateway == false &&
                        asset.isWaves == false}))
        }
        _assets.removeAll()
        _assets.append(contentsOf: filterAssets)
    }
    
    func isValidSearch(name: String, searchText: String) -> Bool {
        
        let searchWords = searchText.components(separatedBy: " ").filter {$0.count > 0}
        
        var validations: [Bool] = []
        for word in searchWords {
            validations.append((name.lowercased() as NSString).range(of: word.lowercased()).location != NSNotFound)
            
        }
        return validations.filter({$0 == true}).count == searchWords.count
    }
}
