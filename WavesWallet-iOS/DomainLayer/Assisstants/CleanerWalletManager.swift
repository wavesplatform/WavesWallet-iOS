//
//  CleanerWalletManager.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension

struct CleanerWalletManager: TSUD, Codable, Mutating  {
    
    private static let key = "com.waves.cleanwallet.settings"
    
    private var isCleanWallet: Bool = false

    static var defaultValue: CleanerWalletManager {
        return CleanerWalletManager(isCleanWallet: false)
    }
    
    static var stringKey: String {
        return key
    }
    
    static func setCleanWallet(isClean: Bool) {
        var settings = CleanerWalletManager.get()
        settings.isCleanWallet = isClean
        CleanerWalletManager.set(settings)
    }
    
    static var isCleanWallet: Bool {
        return CleanerWalletManager.get().isCleanWallet
    }
}
