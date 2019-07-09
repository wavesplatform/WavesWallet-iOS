//
//  ApplicationDebugSettings.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/28/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import WavesSDKExtensions


public struct ApplicationDebugSettings: TSUD, Codable, Mutating {
    
    private static let key: String = "com.waves.debug.settings"

    private var isEnableStage: Bool = false
    private var isEnableNotificationsSettingDev: Bool = false
    
    public static var defaultValue: ApplicationDebugSettings {
        return ApplicationDebugSettings(isEnableStage: false, isEnableNotificationsSettingDev: false)
    }
    
    public static var stringKey: String {
        return key
    }
    
    public static var isEnableStage: Bool {
        return ApplicationDebugSettings.get().isEnableStage
    }
    
    public init() {}
    
    public init(isEnableStage: Bool, isEnableNotificationsSettingDev: Bool) {
        self.isEnableStage = isEnableStage
        self.isEnableNotificationsSettingDev = isEnableNotificationsSettingDev
    }
    
    public static func setupIsEnableStage(isEnable: Bool) {
        var settings = ApplicationDebugSettings.get()
        settings.isEnableStage = isEnable
        ApplicationDebugSettings.set(settings)
    }
    
    public static var isEnableNotificationsSettingDev: Bool {
        return ApplicationDebugSettings.get().isEnableNotificationsSettingDev
    }
    
    public static func setEnableNotificationsSettingDev(isEnable: Bool) {
        var settings = ApplicationDebugSettings.get()
        settings.isEnableNotificationsSettingDev = isEnable
        ApplicationDebugSettings.set(settings)
    }
}
