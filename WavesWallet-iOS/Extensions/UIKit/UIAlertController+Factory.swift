//
//  UIAlertController+Factory.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 14/12/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    static func showAlertForEnabledBiometric() -> UIAlertController {
        let alertController = UIAlertController(title: Localizable.Waves.Profile.Alert.Setupbiometric.title,
                                                message: Localizable.Waves.Profile.Alert.Setupbiometric.message,
                                                preferredStyle: .alert)

        let settingsTitle = Localizable.Waves.Profile.Alert.Setupbiometric.Button.settings
        let settingsAction = UIAlertAction(title: settingsTitle, style: .default) { (_) -> Void in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            guard UIApplication.shared.canOpenURL(settingsUrl) else { return }

            UIApplication.shared.open(settingsUrl, completionHandler: { _ in })
        }

        let cancelTitle = Localizable.Waves.Profile.Alert.Setupbiometric.Button.cancel
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        return alertController
    }
}
