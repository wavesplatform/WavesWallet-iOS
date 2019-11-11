//
//  UseCasesFactory.instance.analyticManagerswift
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
import WavesSDKCrypto

private struct Constants {
    static let AUUIDKey: String = "AUUID"
}

public final class AnalyticManager: AnalyticManagerProtocol {

    private var auuid: String? = nil
    
    public func setAUUID(_ AUUID: String) {
        self.auuid = AUUID
    }
    
    public func trackEvent(_ event: AnalyticManagerEvent) {
        
        var params = event.params
        if let auuid = auuid {
            params[Constants.AUUIDKey] = auuid
        }
        
        Amplitude.instance().logEvent(event.name, withEventProperties: params)
        Analytics.logEvent(event.name.replacingOccurrences(of: " ", with: "_"), parameters: params)
        AppsFlyerTracker.shared()?.trackEvent(event.name, withValues: params)
    }
}
