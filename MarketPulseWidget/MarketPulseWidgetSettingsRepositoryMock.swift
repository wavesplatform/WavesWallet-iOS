//
//  MarketPulseWidgetSettingsRepositoryMock.swift
//  DataLayer
//
//  Created by Pavel Gubin on 30.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import WavesSDK

final class MarketPulseWidgetSettingsRepositoryMock: MarketPulseWidgetSettingsRepositoryProtocol {
    
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        
        var initAssets: [DomainLayer.DTO.MarketPulseSettings.Asset] = []
        
        let btcIcon = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                                                  name: "Bitcoin",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_bitcoin_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let ethIcon = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
                                                  name: "Ethereum",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_ethereum_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let zecIcon = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa",
                                                  name: "zCash",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_zec_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let btcCashIcon = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy",
                                                      name: "Bitcoin Cash",
                                                      url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_bitcoincash_48.png"),
                                          isSponsored: false,
                                          hasScript: false)
        
        let moneroIcon = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3",
                                                     name: "Monero",
                                                     url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_monero_48.png"),
                                         isSponsored: false,
                                         hasScript: false)
        
        let ltcIcon = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
                                                  name: "Litecoin",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_ltc_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let wavesIcon = DomainLayer.DTO.MarketPulseSettings.Asset.IconStyle(icon: .init(assetId: "WAVES",
                                                    name: "WAVES",
                                                    url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_waves_48.png"),
                                        isSponsored: false,
                                        hasScript: false)
        
        
        
        initAssets.append(.init(id: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                                name: "Bitcoin",
                                iconStyle: btcIcon,
                                amountAsset: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                                priceAsset: "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck"))
        
        initAssets.append(.init(id: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
                                name: "Ethereum",
                                iconStyle: ethIcon,
                                amountAsset: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
                                priceAsset: "WAVES"))
        
        initAssets.append(.init(id: "BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa",
                                name: "zCash",
                                iconStyle: zecIcon,
                                amountAsset: "BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa",
                                priceAsset: "WAVES"))
        
        initAssets.append(.init(id: "zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy",
                                name: "Bitcoin Cash",
                                iconStyle: btcCashIcon,
                                amountAsset: "zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy",
                                priceAsset: "WAVES"))
        
        initAssets.append(.init(id: "5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3",
                                name: "Monero",
                                iconStyle: moneroIcon,
                                amountAsset: "5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3",
                                priceAsset: "WAVES"))
        
        initAssets.append(.init(id: "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
                                name: "Litecoin",
                                iconStyle: ltcIcon,
                                amountAsset: "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
                                priceAsset: "WAVES"))
        
        initAssets.append(.init(id: "WAVES",
                                name: "WAVES",
                                iconStyle: wavesIcon,
                                amountAsset: "WAVES",
                                priceAsset: MarketPulse.eurAssetId))
        
        
        initAssets.append(.init(id: MarketPulse.eurAssetId,
                                name: "",
                                iconStyle: wavesIcon,
                                amountAsset: WavesSDKConstants.wavesAssetId,
                                priceAsset: MarketPulse.eurAssetId))
        
        initAssets.append(.init(id: MarketPulse.usdAssetId,
                                name: "",
                                iconStyle: wavesIcon,
                                amountAsset: WavesSDKConstants.wavesAssetId,
                                priceAsset: MarketPulse.usdAssetId))
        
        return Observable.just(.init(isDarkStyle: false, interval: 10, assets: initAssets))
    }
}
