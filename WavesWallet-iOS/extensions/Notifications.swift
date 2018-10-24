//
//  Notifications.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let changedSpamList = Notification.Name(rawValue: "com.waves.language.notification.changedSpamList")
    /**
     The notification object contained current Language
     */
    static let changedLanguage: Notification.Name = Notification.Name.init("com.waves.language.notification.changedLanguage")
}
