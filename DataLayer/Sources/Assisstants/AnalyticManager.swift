//
//  FactoryInteractors.instance.analyticManagerswift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/22/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

import Amplitude_iOS
import FirebaseAnalytics
import AppsFlyerLib

public final class AnalyticManager: AnalyticManagerProtocol {

    public func trackEvent(_ event: AnalyticManagerEvent) {

        Amplitude.instance().logEvent(event.name, withEventProperties: event.params)
        Analytics.logEvent(event.name.replacingOccurrences(of: " ", with: "_"), parameters: event.params)
        AppsFlyerTracker.shared()?.trackEvent(event.name, withValues: event.params)
    }
}
