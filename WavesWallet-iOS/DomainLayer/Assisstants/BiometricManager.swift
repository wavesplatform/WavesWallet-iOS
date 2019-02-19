//
//  BiometricManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

extension BiometricType {

    static var biometricByDevice: BiometricType {
        get {
            let current = self.enabledBiometric
            if current == .none {
                
                if Platform.isSupportFaceID {
                    return .faceID
                }
                return .touchID

            } else {
                return current
            }
        }
    }

    static var enabledBiometric: BiometricType {
        get {
            let context = LAContext()

            var error: NSError? = nil
            let result = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                }
            } else {
                return result ? .touchID : .none
            }
        }
    }
}

final class BiometricManager {

    static var touchIDTypeText: String {
        return type == .faceID ? Localizable.Waves.General.Biometric.Faceid.title : Localizable.Waves.General.Biometric.Touchid.title
    }
    
    static var type: BiometricType {
        get {
            return BiometricType.enabledBiometric
        }
    }
}
