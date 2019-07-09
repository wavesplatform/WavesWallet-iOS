//
//  NewUserWithoutBackupStorageTrack.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import DomainLayer

struct NewUserWithoutBackupStorageTrack {
    
    struct MetaData: Codable, TSUD {
        private static let key: String = "com.waves.analytics.event.newUserWithoutBackupStorage"
        
        var count: UInt = 0
        
        init() { }
        
        static var defaultValue: MetaData {
            return MetaData()
        }
        
        static var stringKey: String {
            return key
        }
    }
    
    static func sendEvent() {
       
        var metaData = MetaData.get()
        metaData.count = metaData.count + 1
        MetaData.set(metaData)
        
        UseCasesFactory
        .instance
        .analyticManager
        .trackEvent(.createANewAccount(.newUserWithoutBackup(count: metaData.count)))
    }
}
