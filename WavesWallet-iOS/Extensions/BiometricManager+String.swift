//
//  BiometricManager+String.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 20.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

extension BiometricManager {
    public static var touchIDTypeText: String {
        return type == .faceID ? Localizable.Waves.General.Biometric.Faceid.title : Localizable.Waves.General.Biometric.Touchid.title
    }
}

