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
    private var _assets: [DomainLayer.DTO.SmartAssetBalance] = []
    private var _isMyList = false
    
    func assets(filters: [AssetList.DTO.Filter], isMyList: Bool) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
            guard let owner = self else { return Observable.empty() }
            
            owner._isMyList = isMyList
            
            let assets = owner.accountBalanceInteractor.balances()
            let accountSettings = owner.accountSettings.accountSettings(accountAddress: wallet.address)
            
            let merge = Observable.zip(assets, accountSettings).map({ [weak self] (assets, settings) -> [DomainLayer.DTO.SmartAssetBalance] in
                
                guard let strongSelf = self else { return [] }

                let isEnableSpam = settings?.isEnabledSpam ?? false
                
                if filters.contains(.all) {
                    
                    if isEnableSpam {
                        self?._assets = assets.filter({$0.asset.isSpam == false})
                    }
                    else {
                        self?._assets = assets
                    }
                }
                else {
                    self?.filterAssets(filters: filters, assets: assets, isEnableSpam: isEnableSpam)
                }
                
                return strongSelf.filterIsMyAsset(strongSelf._assets)
            })
            
            let search = owner.searchString
                .asObserver().skip(1)
                .map { [weak self] searchString -> [DomainLayer.DTO.SmartAssetBalance] in
                    
                    guard let strongSelf = self else { return [] }
                    return strongSelf.filterIsMyAsset(strongSelf._assets)
            }
            
            return Observable
                .merge([merge, search])
                .map { [weak self] assets -> [DomainLayer.DTO.SmartAssetBalance] in
                    
                    guard let strongSelf = self else { return [] }
                    
                    let searchText = (try? self?.searchString.value() ?? "") ?? ""
                    
                    let newAssets = assets.filter {
                        let asset = $0.asset
                        return strongSelf.isValidSearch(name: asset.displayName, searchText: searchText)
                    }
                    
                    return strongSelf.filterIsMyAsset(newAssets)
            }
        })
       
        
    }
    
    func searchAssets(searchText: String) {
        searchString.onNext(searchText)
    }
}


private extension AssetListInteractor {
    
    func filterIsMyAsset(_ assets: [DomainLayer.DTO.SmartAssetBalance]) -> [DomainLayer.DTO.SmartAssetBalance] {
        return _isMyList ? assets.filter({$0.avaliableBalance > 0 }) : assets
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
