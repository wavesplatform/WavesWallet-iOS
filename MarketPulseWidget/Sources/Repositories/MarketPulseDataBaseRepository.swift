//
//  MarketPulseRepository.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 01.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import DomainLayer

final class MarketPulseDataBaseRepository: MarketPulseDataBaseRepositoryProtocol {
    
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]> {
        return Observable.create({ (subscribe) -> Disposable in
            
            guard let realm = try? Realm() else {
                return Disposables.create()
            }
            
            let objects = realm.objects(MarketPulseAsset.self).sorted(by: {$0.indexLevel < $1.indexLevel}).map { MarketPulse.DTO.Asset(asset: $0)}
            subscribe.onNext(objects)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func saveAsssets(assets: [MarketPulse.DTO.Asset]) -> Observable<Bool> {
        return Observable.create({ (subscribe) -> Disposable in
            
            guard let realm = try? Realm() else {
                subscribe.onNext(false)
                return Disposables.create()
            }

            do {
                try realm.write {
                    realm.delete(realm.objects(MarketPulseAsset.self))
                    for (index, asset) in assets.enumerated() {
                        realm.add(MarketPulseAsset(asset: asset, index: index))
                    }
                }
                subscribe.onNext(true)
            }
            catch _ {
                subscribe.onNext(false)
            }
            
            subscribe.onCompleted()
            
            return Disposables.create()
        })

    }
}

private extension MarketPulseAsset {
    
    convenience init(asset: MarketPulse.DTO.Asset, index: Int) {
        self.init()
        
        id = asset.id
        name = asset.name
        iconUrl = asset.icon.url
        hasScript = asset.hasScript
        isSponsored = asset.isSponsored
        firstPrice = asset.firstPrice
        lastPrice = asset.lastPrice
        volume = asset.volume
        volumeWaves = asset.volumeWaves
        quoteVolume = asset.quoteVolume
        amountAsset = asset.amountAsset
        indexLevel = indexLevel
    }
}

private extension MarketPulse.DTO.Asset {
    
    init(asset: MarketPulseAsset) {
        id = asset.id
        name = asset.name
        icon = DomainLayer.DTO.Asset.Icon(assetId: id, name: name, url: asset.iconUrl)
        hasScript = asset.hasScript
        isSponsored = asset.isSponsored
        firstPrice = asset.firstPrice
        lastPrice = asset.lastPrice
        volume = asset.volume
        volumeWaves = asset.volumeWaves
        quoteVolume = asset.quoteVolume
        amountAsset = asset.amountAsset
    }
}
