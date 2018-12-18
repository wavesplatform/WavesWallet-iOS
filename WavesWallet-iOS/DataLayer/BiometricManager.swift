//
//  BiometricManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import LocalAuthentication
import Device_swift

enum BiometricType {
    case none
    case touchID
    case faceID
}

//TODO: Need send pull to request to Device Library
private struct Constants {
    static let ipadsFaceId = ["iPad8,5",
                              "iPad8,6",
                              "iPad8,7",
                              "iPad8,8",
                              "iPad8,1",
                              "iPad8,2",
                              "iPad8,3",
                              "iPad8,4"]

}

extension BiometricType {

    static var biometricByDevice: BiometricType {
        get {
            let current = self.enabledBiometric
            if current == .none {

                switch DeviceType.current {
                case .iPhoneX,
                     .iPhoneXS,
                     .iPhoneXSMax,
                     .iPhoneXR:
                     return .faceID
                default:

                    let model = UIDevice.current.deviceModel
                    if Constants.ipadsFaceId.contains(model) {
                        return .faceID
                    }
                    return .touchID
                }

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
