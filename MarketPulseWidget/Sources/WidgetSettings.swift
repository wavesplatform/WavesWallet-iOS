//
//  WidgetSettings.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 01.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import RxSwift
import WavesSDKExtensions

extension WidgetSettings: ReactiveCompatible {}

struct WidgetSettings: TSUD, Codable, Mutating {
    
    private static let key = "com.waves.widget.settings.currency"
    
    init() {}
    
    var currency: String = ""
    
    init(currency: String) {
        self.currency = currency
    }
    
    static var defaultValue: WidgetSettings {
        return WidgetSettings(currency: MarketPulse.Currency.usd.rawValue)
    }
    
    static var stringKey: String {
        return key
    }
  
    static func setCurrency(currency: MarketPulse.Currency) {
        var settings = WidgetSettings.get()
        settings.currency = currency.rawValue
        WidgetSettings.set(settings)
    }
}

extension Reactive where Base == WidgetSettings {
    
    static func currency() -> Observable<MarketPulse.Currency> {
        return WidgetSettings.rx.get().flatMap({ (settings) -> Observable<MarketPulse.Currency> in
            
            guard let currency = MarketPulse.Currency(rawValue: settings.currency) else {
                return Observable.empty()
            }
            return Observable.just(currency)
        })
    }
}

