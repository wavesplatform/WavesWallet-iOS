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
    
    private var cleanAccounts: Set<String> = Set<String>()
    
    init() {
        self.cleanAccounts = .init()
    }
    
    static var defaultValue: CleanerWalletManager {
        return CleanerWalletManager()
    }
    
    static var stringKey: String {
        return key
    }
    
    static func setCleanWallet(accountAddress: String) {
        var settings = CleanerWalletManager.get()
        settings.cleanAccounts.insert(accountAddress)
        CleanerWalletManager.set(settings)
    }
    
    static func isCleanWallet(by accountAddress: String) -> Bool {
        return CleanerWalletManager.get().cleanAccounts.contains(accountAddress)
    }
}
