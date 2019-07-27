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
    private var debugButtonPosition: CGPoint? = nil
    
    public static var defaultValue: ApplicationDebugSettings {
        return ApplicationDebugSettings(isEnableStage: false,
                                        isEnableNotificationsSettingDev: false,
                                        debugButtonPosition: nil)
    }
    
    public static var stringKey: String {
        return key
    }
    
    public static var isEnableStage: Bool {
        return ApplicationDebugSettings.get().isEnableStage
    }
    
    public static var debugButtonPosition: CGPoint? {
        
        get {
            return ApplicationDebugSettings.get().debugButtonPosition
        }
        
        set {
            var settings = ApplicationDebugSettings.get()
            settings.debugButtonPosition = newValue
            ApplicationDebugSettings.set(settings)
        }
    }
    
    public init() {}
    
    public init(isEnableStage: Bool, isEnableNotificationsSettingDev: Bool, debugButtonPosition: CGPoint?) {
        self.isEnableStage = isEnableStage
        self.isEnableNotificationsSettingDev = isEnableNotificationsSettingDev
        self.debugButtonPosition = debugButtonPosition
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
