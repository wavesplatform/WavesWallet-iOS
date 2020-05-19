//
//  UseCasesFactory.instance.analyticManagerswift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/22/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Amplitude_iOS
import DomainLayer
import FirebaseAnalytics
import Foundation
import WavesSDKCrypto

private struct Constants {
    static let AUUIDKey: String = "AUUID"
}

public final class AnalyticManager: AnalyticManagerProtocol {
    private var uid: String?

    public func setUID(uid: String) {
        self.uid = uid
    }

    public func trackEvent(_ event: AnalyticManagerEvent) {
        var params = event.params
        if let uid = uid {
            params["userId"] = uid
            Amplitude.instance()?.setUserId(uid)
            Analytics.setUserID(uid)
        }
        
        params["userType"] = "seed"
        params["platform"] = "iOS"

        Amplitude.instance().logEvent(event.name, withEventProperties: params)
        Analytics.logEvent(event.name.replacingOccurrences(of: " ", with: "_"), parameters: params)
    }
}
