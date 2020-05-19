//
//  WidgetAnalyticManager.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 29.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Amplitude_iOS

final class WidgetAnalyticManagerInitialization {
    
    struct Resources {
        
        typealias PathForFile = String
        
        let googleServiceInfo: PathForFile
        let appsflyerInfo: PathForFile
        let amplitudeInfo: PathForFile
    }
    
    
    static func setup(resources: Resources) {

        if let apiKey = NSDictionary(contentsOfFile: resources.amplitudeInfo)?["API_KEY"] as? String {
            Amplitude.instance()?.initializeApiKey(apiKey)
            Amplitude.instance()?.setDeviceId(UIDevice.uuid)
        }
    }
}

    
final class WidgetAnalyticManager: AnalyticManagerProtocol {
        
    static let shared = WidgetAnalyticManager()
        
    func setUID(uid: String) {}
    func trackEvent(_ event: AnalyticManagerEvent) {
        Amplitude.instance().logEvent(event.name, withEventProperties: event.params)        
    }
}
