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
    private let accountSettings: AccountSettingsRepositoryProtocol = FactoryRepositories.instance.accountSettingsRepository
    private let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    private let searchString: BehaviorSubject<String> = BehaviorSubject<String>(value: "")
    private var filteredAssets: [DomainLayer.DTO.SmartAssetBalance] = []
    private var cachedAssets: [DomainLayer.DTO.SmartAssetBalance] = []
    private var isMyList = false
    
    func assets(filters: [AssetList.DTO.Filter], isMyList: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
            guard let self = self else { return Observable.empty() }
            
            self.isMyList = isMyList
            
            let assets = self.getCachedAssets()
            let accountSettings = self.accountSettings.accountSettings(accountAddress: wallet.address)
            
            let merge = Observable.zip(assets, accountSettings).map({ [weak self] (assets, settings) -> [DomainLayer.DTO.SmartAssetBalance] in
                
                guard let self = self else { return [] }
                self.cachedAssets = assets
                
                let isEnableSpam = settings?.isEnabledSpam ?? false
                
                if filters.contains(.all) {
                    
                    if isEnableSpam {
                        self.filteredAssets = assets.filter({$0.asset.isSpam == false})
                    }
                    else {
                        self.filteredAssets = assets
                    }
                }
                else {
                    self.filterAssets(filters: filters, assets: assets, isEnableSpam: isEnableSpam)
                }
                
                return self.filterIsMyAsset(self.filteredAssets)
            })
            
            let search = self.searchString
                .asObserver().skip(1)
                .map { [weak self] searchString -> [DomainLayer.DTO.SmartAssetBalance] in
                    
                    guard let self = self else { return [] }
                    return self.filterIsMyAsset(self.filteredAssets)
            }
            
            return Observable
                .merge([merge, search])
                .map { [weak self] assets -> [DomainLayer.DTO.SmartAssetBalance] in
                    
                    guard let self = self else { return [] }
                    
                    let searchText = (try? self.searchString.value()) ?? ""
                    
                    let newAssets = assets.filter {
                        let asset = $0.asset
                        return self.isValidSearch(name: asset.displayName, searchText: searchText)
                    }
                    
                    return self.filterIsMyAsset(newAssets)
            }
        })
        .catchError({ (error) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
            return Observable.just([])
        })
    }
    
    func searchAssets(searchText: String) {
        searchString.onNext(searchText)
    }
}


private extension AssetListInteractor {
    
    func getCachedAssets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        if cachedAssets.count > 0 {
            return Observable.just(cachedAssets)
        }
        return accountBalanceInteractor.balances()
    }
    
    func filterIsMyAsset(_ assets: [DomainLayer.DTO.SmartAssetBalance]) -> [DomainLayer.DTO.SmartAssetBalance] {
        return isMyList ? assets.filter({$0.availableBalance > 0 }) : assets
    }
    
    func filterAssets(filters: [AssetList.DTO.Filter], assets: [DomainLayer.DTO.SmartAssetBalance], isEnableSpam: Bool) {
        
        var filterAssets: [DomainLayer.DTO.SmartAssetBalance] = []
                
        if filters.contains(.waves) {
            
            filterAssets.append(contentsOf: assets.filter({
                let asset = $0.asset
                
                return asset.isFiat == false &&
                    asset.isWavesToken == false &&
                    asset.isGateway == false &&
                    asset.isWaves == true}))
        }
        
        if filters.contains(.cryptoCurrency) {
            
                filterAssets.append(contentsOf: assets.filter({
                    let asset = $0.asset
                    
                    return asset.isFiat == false &&
                        asset.isWavesToken == false &&
                        asset.isGateway == true &&
                        asset.isWaves == false}))
        }
        
        if filters.contains(.fiat) {
            
                filterAssets.append(contentsOf: assets.filter({
                    let asset = $0.asset
                    
                    return asset.isFiat == true &&
                        asset.isWavesToken == false &&
                        asset.isGateway == true &&
                        asset.isWaves == false}))
        }
        
        if filters.contains(.wavesToken) {
            
                filterAssets.append(contentsOf: assets.filter({
                    let asset = $0.asset
                    
                    return asset.isFiat == false &&
                        asset.isWavesToken == true &&
                        asset.isGateway == false &&
                        asset.isWaves == false &&
                        asset.isSpam == false }))
        }
        
        if filters.contains(.spam) && !isEnableSpam {
            
            filterAssets.append(contentsOf: assets.filter({
                let asset = $0.asset
                
                return asset.isSpam == true }))
        }
        
        filteredAssets.removeAll()
        filteredAssets.append(contentsOf: filterAssets)
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
