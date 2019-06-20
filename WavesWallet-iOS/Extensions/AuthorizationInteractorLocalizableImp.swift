//
//  AuthorizationInteractorLocalizableImp.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 20.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

struct AuthorizationInteractorLocalizableImp: AuthorizationInteractorLocalizableProtocol {
    
    var fallbackTitle: String {
        return Localizable.Waves.Biometric.localizedFallbackTitle
    }
    
    var cancelTitle: String {
        return Localizable.Waves.Biometric.localizedCancelTitle
    }
    
    var readFromkeychain: String {
        return Localizable.Waves.Biometric.readfromkeychain
    }
    
    var saveInkeychain: String {
        return Localizable.Waves.Biometric.saveinkeychain
    }
}
