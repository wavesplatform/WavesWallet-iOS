//
//  BiometricManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import LocalAuthentication

class BiometricManager {
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    static var touchIDTypeText: String {
        return type == .faceID ? "Face ID" : "Touch ID"
    }
    
    static var type: BiometricType {
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
