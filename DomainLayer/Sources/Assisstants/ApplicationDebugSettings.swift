//
//  ApplicationDebugSettings.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/28/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Extensions
import WavesSDKExtensions


public struct ApplicationDebugSettings: TSUD, Codable, Mutating {
    
    private static let key: String = "com.waves.debug.settings"

    private var isEnableStage: Bool = false
    private var isEnableEnviromentTest: Bool = false
    private var debugButtonPosition: CGPoint? = nil
    
    public static var defaultValue: ApplicationDebugSettings {
        return ApplicationDebugSettings(isEnableStage: false,
                                        debugButtonPosition: nil,
                                        isEnableEnviromentTest: false)
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
        
    public init(isEnableStage: Bool,
                debugButtonPosition: CGPoint?,
                isEnableEnviromentTest: Bool) {
        self.isEnableStage = isEnableStage
        self.isEnableEnviromentTest = isEnableEnviromentTest
        self.debugButtonPosition = debugButtonPosition
    }
    
    
    public static func setupIsEnableStage(isEnable: Bool) {
        var settings = ApplicationDebugSettings.get()
        settings.isEnableStage = isEnable
        ApplicationDebugSettings.set(settings)
    }
    
    public static var isEnableEnviromentTest: Bool {
        return ApplicationDebugSettings.get().isEnableEnviromentTest
    }
    
    public static func setEnableEnviromentTest(isEnable: Bool) {
        var settings = ApplicationDebugSettings.get()
        settings.isEnableEnviromentTest = isEnable
        ApplicationDebugSettings.set(settings)
    }
}
