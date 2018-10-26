//
//  BiometricType.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension BiometricType {

    var title: String? {
        switch self {
        case .none:
            return nil

        case .touchID:
            return Localizable.Waves.General.Biometric.Touchid.title

        case .faceID:
            return Localizable.Waves.General.Biometric.Faceid.title
        }
    }

    var icon: UIImage? {

        switch self {
        case .none:
            return nil

        case .touchID:
            return Images.touchid48Submit300.image

        case .faceID:
            return Images.faceid48Submit300.image
        }
    }
}
