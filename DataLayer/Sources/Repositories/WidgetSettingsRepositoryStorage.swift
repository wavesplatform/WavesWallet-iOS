//
//  MarketPulseWidgetSettingsRepositoryStorage.swift
//  DataLayer
//
//  Created by rprokofev on 07.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions
import RxSwift


private enum Constants {
    static let settingsKey = "widget.settings"
    static let userGroupsKey = "group.com.wavesplatform"
}


final class WidgetSettingsRepositoryStorage: WidgetSettingsRepositoryProtocol {
    
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings?> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            if let settingsData = self.userDefaults.object(forKey: Constants.settingsKey) as? Data {
                if let settings = try? JSONDecoder().decode(DomainLayer.DTO.MarketPulseSettings.self, from: settingsData) {
                    subscribe.onNext(settings)
                }
                else {
                    subscribe.onNext(nil)
                }
            }
            else {
                subscribe.onNext(nil)
            }
            
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func saveSettings(_ settings: DomainLayer.DTO.MarketPulseSettings) -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in
            
            guard let self = self else { return Disposables.create() }
            
            do {
                let encodedData = try JSONEncoder().encode(settings)
                self.userDefaults.set(encodedData, forKey: Constants.settingsKey)
                subscribe.onNext(settings)
                subscribe.onCompleted()
            }
            catch _ {
                subscribe.onError(RepositoryError.fail)
            }
            
            return Disposables.create()
        })
    }
    
    
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: Constants.userGroupsKey) ?? .standard
    }
}
