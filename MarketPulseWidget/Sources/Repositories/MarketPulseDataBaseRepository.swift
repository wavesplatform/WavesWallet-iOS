//
//  MarketPulseRepository.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 01.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import Extensions

private enum Constants {
    static let key = "widget.settings.chachedAssets"
}

final class MarketPulseDataBaseRepository: MarketPulseDataBaseRepositoryProtocol {
    
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]> {
        return Observable.create({ (subscribe) -> Disposable in
            
            if let assetsData = UserDefaults.standard.object(forKey: Constants.key) as? Data {
                if let assets = try? JSONDecoder().decode([MarketPulse.DTO.Asset].self, from: assetsData) {
                    subscribe.onNext(assets)
                }
                else {
                    subscribe.onNext([])
                }
            }
            else {
                subscribe.onNext([])
            }
            
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func saveAsssets(assets: [MarketPulse.DTO.Asset]) -> Observable<Bool> {
        return Observable.create({ (subscribe) -> Disposable in
            
            do {
                let encodedData = try JSONEncoder().encode(assets)
                UserDefaults.standard.set(encodedData, forKey: Constants.key)
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
