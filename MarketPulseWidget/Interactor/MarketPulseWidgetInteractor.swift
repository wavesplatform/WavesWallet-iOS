//
//  MarketPulseWidgetInteractor.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import DomainLayer
import DataLayer
import WavesSDKExtensions
import Extensions

protocol MarketPulseWidgetInteractorProtocol {
    func assets() -> Observable<[MarketPulse.DTO.Asset]>
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]>
    func settings() -> Observable<MarketPulse.DTO.Settings>
}

final class MarketPulseWidgetInteractor: MarketPulseWidgetInteractorProtocol {
  
    private let widgetSettingsRepository: MarketPulseWidgetSettingsRepositoryProtocol = MarketPulseWidgetSettingsRepositoryMock()
    
    func settings() -> Observable<MarketPulse.DTO.Settings> {
        
        return Observable.zip(WidgetSettings.rx.currency(),
        widgetSettingsRepository.settings())
            .flatMap({ (currency, marketPulseSettings) -> Observable<MarketPulse.DTO.Settings> in
                return Observable.just(MarketPulse.DTO.Settings(currency: currency, isDarkMode: marketPulseSettings.isDarkStyle))
            })
    }
    
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]> {
        
        
        return Observable.empty()
    }
    
    
    func assets() -> Observable<[MarketPulse.DTO.Asset]> {
        
//        return Observable.empty()
        
        struct Asset {
            struct IconStyle {
                let icon: DomainLayer.DTO.Asset.Icon
                let isSponsored: Bool
                let hasScript: Bool
            }
            
            let id: String
            let name: String
            let iconStyle: IconStyle
            let amountAsset: String
            let priceAsset: String
        }
    
        struct Settings {
            let interval: Int
            let isDarkStyle: Bool
            let assets: [Asset]
        }
        
        var initAssets: [Asset] = []
        
        let btcIcon = Asset.IconStyle(icon: .init(assetId: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                                                  name: "Bitcoin",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_bitcoin_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let ethIcon = Asset.IconStyle(icon: .init(assetId: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
                                                  name: "Ethereum",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_ethereum_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let zecIcon = Asset.IconStyle(icon: .init(assetId: "BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa",
                                                  name: "zCash",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_zec_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let btcCashIcon = Asset.IconStyle(icon: .init(assetId: "zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy",
                                                  name: "Bitcoin Cash",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_bitcoincash_48.png"),
                                          isSponsored: false,
                                          hasScript: false)

        let moneroIcon = Asset.IconStyle(icon: .init(assetId: "5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3",
                                                     name: "Monero",
                                                     url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_monero_48.png"),
                                         isSponsored: false,
                                         hasScript: false)
        
        let ltcIcon = Asset.IconStyle(icon: .init(assetId: "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
                                                  name: "Litecoin",
                                                  url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_ltc_48.png"),
                                      isSponsored: false,
                                      hasScript: false)
        
        let wavesIcon = Asset.IconStyle(icon: .init(assetId: "WAVES",
                                                    name: "WAVES",
                                                    url: "https://d1jh0rcszsaxik.cloudfront.net/assset_icons/logo_waves_48.png"),
                                        isSponsored: false,
                                        hasScript: false)

        
        initAssets.append(.init(id: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                                name: "Bitcoin",
                                iconStyle: btcIcon,
                                amountAsset: "WAVES",
                                priceAsset: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS"))

//
//        initAssets.append(.init(id: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
//                               name: "Bitcoin",
//                               iconStyle: btcIcon,
//                               amountAsset: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
//                               priceAsset: "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck"))


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
                               amountAsset: WavesSDKConstants.wavesAssetId, priceAsset: MarketPulse.eurAssetId))
        
        initAssets.append(.init(id: MarketPulse.usdAssetId,
                               name: "",
                               iconStyle: wavesIcon,
                               amountAsset: WavesSDKConstants.wavesAssetId, priceAsset: MarketPulse.usdAssetId))
        
        return WavesSDK.shared.services
                .dataServices
                .pairsPriceDataService
                .pairsPrice(query: .init(pairs: initAssets.map { model in
                    return DataService.Query.PairsPrice.Pair(amountAssetId: model.amountAsset,
                                                             priceAssetId: model.priceAsset)
                }))
                .map { (models) -> [MarketPulse.DTO.Asset] in
                    
                    var pairs: [MarketPulse.DTO.Asset] = []

                    for (index, model) in models.enumerated() {
                        let asset = initAssets[index]
                        
                        pairs.append(MarketPulse.DTO.Asset(id: asset.id,
                                                           name: asset.name,
                                                           icon: asset.iconStyle.icon,
                                                           hasScript: asset.iconStyle.hasScript,
                                                           isSponsored: asset.iconStyle.isSponsored,
                                                           firstPrice: model.firstPrice,
                                                           lastPrice: model.lastPrice,
                                                           volume: model.volume,
                                                           volumeWaves: model.volumeWaves ?? 0,
                                                           quoteVolume: model.quoteVolume ?? 0,
                                                           amountAsset: asset.amountAsset))
                    }
                    
                    return pairs
                }

    }
}
