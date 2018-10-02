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

    static var current: BiometricType {
        get {
            let context = LAContext()

            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
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
                return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
            }
        }
    }
}

final class BiometricManager {

    static var touchIDTypeText: String {
        return type == .faceID ? Localizable.General.Biometric.Faceid.title : Localizable.General.Biometric.Touchid.title
    }
    
    static var type: BiometricType {
        get {
            return BiometricType.current
        }
    }
}
