//
//  MarketPulseWidgetSettingsRepositoryStorage.swift
//  DataLayer
//
//  Created by rprokofev on 07.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions
import RxSwift

final class WidgetSettingsRepositoryStorage: WidgetSettingsRepositoryProtocol {
    
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings?> {
        
        return Observable.create({ observer -> Disposable in
            
            //TODO: Remove WalletEnvironment.current.scheme
            let realm = WidgetRealmFactory.realm(chainId: WalletEnvironment.current.scheme)
            if let object = realm?.objects(WidgetSettings.self).first, let settings = object.marketPulseSettings {
                observer.onNext(settings)
            } else {
                observer.onNext(nil)
            }
            observer.onCompleted()
            
            return Disposables.create()
        })
    }
 
    func saveSettings(_ settings: DomainLayer.DTO.MarketPulseSettings) -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        
        return Observable.create({ observer -> Disposable in
            
            do {
                //TODO: Remove WalletEnvironment.current.scheme
                guard let realm = WidgetRealmFactory.realm(chainId: WalletEnvironment.current.scheme) else {
                    observer.onError(RepositoryError.fail)
                    return Disposables.create()
                }
                
                try realm.write {
                    
                    let result = realm.objects(WidgetSettings.self)
                    realm.delete(result)
                    realm.add(settings.settings)
                    
                }
             
                observer.onNext(settings)
                observer.onCompleted()
                return Disposables.create()
            } catch _ {
                observer.onError(RepositoryError.fail)
                return Disposables.create()
            }
                        
        })
    }
}

fileprivate extension WidgetSettingsAsset {
    
    var marketPulseIconStyle: AssetLogo.Icon {
        
        return AssetLogo.Icon.init(assetId: icon.assetId,
                                   name: icon.name,
                                   url: icon.url,
                                   isSponsored: icon.isSponsored,
                                   hasScript: icon.hasScript)
    }
}

fileprivate extension WidgetSettings {
    
    var marketPulseInterval: DomainLayer.DTO.MarketPulseSettings.Interval? {
        
        switch self.interval {
        case 60:
            return .m1
        
        case 300:
            return .m5
    
        case 600:
            return .m10

        case 0:
            return .manually
            
        default:
            return nil
        }
    }
    
    var marketPulseAssets: [DomainLayer.DTO.MarketPulseSettings.Asset] {
        
        return self.assets.toArray().map { DomainLayer.DTO.MarketPulseSettings.Asset.init(id: $0.id,
                                                                                          name: $0.name,
                                                                                          icon: $0.marketPulseIconStyle,
                                                                                          amountAsset: $0.amountAsset,
                                                                                          priceAsset: $0.priceAsset) }
    }
    
    var marketPulseSettings: DomainLayer.DTO.MarketPulseSettings? {

        guard let interval = self.marketPulseInterval else { return nil }
        
        return DomainLayer.DTO.MarketPulseSettings.init(isDarkStyle: self.isDarkStyle,
                                                 interval: interval,
                                                 assets: marketPulseAssets)
    }
}

fileprivate extension DomainLayer.DTO.MarketPulseSettings {

    var realmInterval: Int {
        
        switch self.interval {
        case .m1:
            return 60
            
        case .m5:
            return 300
            
        case .m10:
            return 600
            
        case .manually:
            return 0
            
        }
    }
    
    var realmAssets: [WidgetSettingsAsset] {
        
        return self.assets.map({ (asset) -> WidgetSettingsAsset in
            
            let realmAsset = WidgetSettingsAsset()
            
            let icon = WidgetSettingsAssetIcon()
            
            icon.assetId = asset.icon.assetId
            icon.hasScript = asset.icon.hasScript
            icon.isSponsored = asset.icon.isSponsored
            icon.name = asset.icon.name
            icon.url = asset.icon.url
            
            realmAsset.id = asset.id
            realmAsset.name = asset.name
            realmAsset.icon = icon
            realmAsset.priceAsset = asset.priceAsset
            realmAsset.amountAsset = asset.amountAsset
            
            return realmAsset
        })
    }
    
    var settings: WidgetSettings {
        
        let settings = WidgetSettings()
        
        settings.interval = realmInterval
        settings.isDarkStyle = isDarkStyle
        settings.assets.append(objectsIn: realmAssets)
        
        return settings
    }
}


