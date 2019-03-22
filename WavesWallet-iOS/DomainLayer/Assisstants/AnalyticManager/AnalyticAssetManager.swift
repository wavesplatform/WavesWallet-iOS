//
//  AnalyticAssetManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/22/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

struct AnalyticAssetManager: TSUD, Codable, Mutating  {

    private static let key: String = "com.waves.analytic.generalAssets"
    
    private var assetsIds: Set<String> = Set<String>()
    private var zeroAssetsIds: Set<String> = Set<String>()

    init(assetsIds: Set<String>, zeroAssetsIds: Set<String>) {
        self.assetsIds = assetsIds
        self.zeroAssetsIds = zeroAssetsIds
    }
    
    init() {
        assetsIds = .init()
        zeroAssetsIds = .init()
    }
    
    static var defaultValue: AnalyticAssetManager {
        return AnalyticAssetManager(assetsIds: .init(), zeroAssetsIds: .init())
    }

    static var stringKey: String {
        return key
    }

    static func trackFromZeroBalances(assets: [DomainLayer.DTO.SmartAssetBalance], accountAddress: String) {
    
        let zeroAssets = assets.filter { $0.totalBalance == 0 }
        saveZeroBalances(zeroAssets: zeroAssets, accountAddress: accountAddress)
        
        var setting = AnalyticAssetManager.get()
        var hasChanges = false
        
        let assetBalances = assets.filter { $0.totalBalance > 0 }
        for asset in assetBalances {
            
            let assetId = AnalyticAssetManager.assetIdKey(assetId: asset.assetId, accountAddress: accountAddress)

            if setting.zeroAssetsIds.contains(assetId) && !setting.assetsIds.contains(assetId) {
                setting.assetsIds.insert(assetId)
                hasChanges = true
                
                AnalyticManager.trackEvent(.walletStart(.balanceFromZero(assetName: asset.asset.displayName)))
            }
        }
        
        if hasChanges {
            AnalyticAssetManager.set(setting)
        }
    }
    
    private static func saveZeroBalances(zeroAssets: [DomainLayer.DTO.SmartAssetBalance], accountAddress: String) {
        
        var setting = AnalyticAssetManager.get()
        var hasChanges = false
        
        for asset in zeroAssets {
            
            let assetId = AnalyticAssetManager.assetIdKey(assetId: asset.assetId, accountAddress: accountAddress)
            
            if !setting.zeroAssetsIds.contains(assetId) {
                setting.zeroAssetsIds.insert(assetId)
                hasChanges = true
            }
        }
        
        if hasChanges {
            AnalyticAssetManager.set(setting)
        }
    }
    
    private static func assetIdKey(assetId: String, accountAddress: String) -> String {
        return assetId + accountAddress
    }
}
