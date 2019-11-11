//
//  PushNotificationsCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 07.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import WavesSDKExtensions

private struct PushNotificationsAlertSettings: TSUD, Codable, Mutating {
    
    var hasShowAlert: Bool

    private enum Constants {
        static let key: String = "com.waves.pushNotifications.settings"
    }

    init(hasShowAlert: Bool) {
        self.hasShowAlert = hasShowAlert
    }

    init() {
        hasShowAlert = false
    }
    
    static var defaultValue: PushNotificationsAlertSettings {
        return PushNotificationsAlertSettings(hasShowAlert: false)
    }

    static var stringKey: String {
        return Constants.key
    }
}

final class PushNotificationsCoordinator: NSObject, Coordinator  {
   
    var childCoordinators: [Coordinator] = []
    
    var parent: Coordinator?
    
    func start() {
        
        if PushNotificationsAlertSettings.get().hasShowAlert == false {
            
            let pushAlert = PushNotificationsAlertView.show()
            pushAlert.activateAction = { [weak self] in
                guard let self = self else { return }
                self.activateNotifications()
            }
            pushAlert.laterAction = { [weak self] in
                guard let self = self else { return }
                self.laterAction()
            }
        }
        else {
            removeFromParentCoordinator()
        }
    }

    private func activateNotifications() {
        PushNotificationsManager.registerRemoteNotifications()
        PushNotificationsAlertSettings.set(.init(hasShowAlert: true))
        removeFromParentCoordinator()
    }
    
    private func laterAction() {
        PushNotificationsAlertSettings.set(.init(hasShowAlert: true))
        removeFromParentCoordinator()
    }
}
