//
//  UIAlertController+Factory.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 14/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit


extension UIAlertController {
    static func showAlertForEnabledBiometric() -> UIAlertController {

        let alertController = UIAlertController (title: Localizable.Waves.Profile.Alert.Setupbiometric.title,
                                                 message: Localizable.Waves.Profile.Alert.Setupbiometric.message,
                                                 preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: Localizable.Waves.Profile.Alert.Setupbiometric.Button.settings, style: .default) { (_) -> Void in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            guard UIApplication.shared.canOpenURL(settingsUrl) else { return }

            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
        }

        let cancelAction = UIAlertAction(title: Localizable.Waves.Profile.Alert.Setupbiometric.Button.cancel, style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)



        return alertController
    }
}
