
//  AuthorizationInteractorLocalizableImp.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 20.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

struct AuthorizationInteractorLocalizableImp: AuthorizationInteractorLocalizableProtocol {
    
    init() {}
    
    var fallbackTitle: String {
        return Localizable.Biometric.localizedFallbackTitle
    }
    
    var cancelTitle: String {
        return Localizable.Biometric.localizedCancelTitle
    }
    
    var readFromkeychain: String {
        return Localizable.Biometric.readfromkeychain
    }
    
    var saveInkeychain: String {
        return Localizable.Biometric.saveinkeychain
    }
}
