//
//  GlobalConstants.swift
//  DomainLayer
//
//  Created by rprokofev on 25.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import Extensions

public enum DomainLayerConstants {

    public enum URL {
        public static let fiatDepositSuccess = "https://waves.exchange/fiatdeposit/success"
        public static let fiatDepositFail = "https://waves.exchange/fiatdeposit/fail"
        public static let advcash = "https://wallet.advcash.com/sci"
    }
    
    // advance cash usd id
    public static let acUSDId: String = "AC_USD"
}

