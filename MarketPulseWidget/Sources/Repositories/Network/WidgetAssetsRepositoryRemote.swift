//
//  WidgetAssetsRepositoryRemote.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import WavesSDKExtensions
import WavesSDK


protocol WidgetAssetsRepositoryProtocol {
    func assets(by ids: [String]) -> Observable<[Asset]>
}

final class WidgetAssetsRepositoryRemote: WidgetAssetsRepositoryProtocol {
    
    private let assetsDataService: WidgetAssetsDataServiceProtocol = WidgetAssetsDataService()
    
    func assets(by ids: [String]) -> Observable<[Asset]> {
        
        let walletEnviroment = WalletEnvironment.Mainnet
        
        return assetsDataService
                .assets(ids: ids)
                .map({ (assets) -> [Asset] in
                
                let map = walletEnviroment.hashMapAssets()
                let mapGeneralAssets = walletEnviroment.hashMapGeneralAssets()
                
                
                return assets.map { Asset(asset: $0,
                                                          info: map[$0.id],
                                                          isSpam: false,
                                                          isMyWavesToken: false,
                                                          isGeneral: mapGeneralAssets[$0.id] != nil) }
            })
    }
}

//TODO: - Duplicate code from DataLayer

fileprivate extension WalletEnvironment {
    
    func hashMapAssets() -> [String: WalletEnvironment.AssetInfo] {
        
        var allAssets = generalAssets
        if let additionalAssets = assets {
            allAssets.append(contentsOf: additionalAssets)
        }
        
        return allAssets.reduce([String: WalletEnvironment.AssetInfo](), { map, info -> [String: WalletEnvironment.AssetInfo] in
            var new = map
            new[info.assetId] = info
            return new
        })
    }
    
    func hashMapGeneralAssets() -> [String: WalletEnvironment.AssetInfo] {
        
        let allAssets = generalAssets
        
        return allAssets.reduce([String: WalletEnvironment.AssetInfo](), { map, info -> [String: WalletEnvironment.AssetInfo] in
            var new = map
            new[info.assetId] = info
            return new
        })
    }
}


fileprivate extension Asset {
    
    init(asset: DataService.DTO.Asset, info: WalletEnvironment.AssetInfo?, isSpam: Bool, isMyWavesToken: Bool, isGeneral: Bool) {
        var isWaves = false
        var isFiat = false
        let isGateway = info?.isGateway ?? false
        let isWavesToken = isFiat == false && isGateway == false && isWaves == false
        var name = asset.name
        
        //TODO: Current code need move to AssetsInteractor!
        if let info = info {
            if info.assetId == WavesSDKConstants.wavesAssetId {
                isWaves = true
            }
            
            name = info.displayName
            isFiat = info.isFiat
        }
        
        self.init(id: asset.id,
                  gatewayId: info?.gatewayId,
                  wavesId: info?.wavesId,
                  name: name,
                  precision: asset.precision,
                  description: asset.description,
                  height: asset.height,
                  timestamp: asset.timestamp,
                  sender: asset.sender,
                  quantity: asset.quantity,
                  ticker: asset.ticker,
                  isReusable: asset.reissuable,
                  isSpam: isSpam,
                  isFiat: isFiat,
                  isGeneral: isGeneral,
                  isMyWavesToken: isMyWavesToken,
                  isWavesToken: isWavesToken,
                  isGateway: isGateway,
                  isWaves: isWaves,
                  modified: Date(),
                  addressRegEx: info?.addressRegEx ?? "",
                  iconLogoUrl: info?.iconUrls?.default,
                  hasScript: asset.hasScript,
                  minSponsoredFee: asset.minSponsoredFee ?? 0,
                  gatewayType: info?.gatewayType)
    }
}
