//
//  DeviceID.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public struct DeviceId {
    
    static var id: String {
        
        if let id = DeviceIdStorage.value {
            return id
        } else {
            let id = UUID().uuidString
            DeviceIdStorage.value = id
            return id
        }
    }
}

private struct DeviceIdStorage: TSUD {
    
    private static let key: String = "com.waves.device.id"
    
    static var defaultValue: String? {
        return nil
    }
    
    static var stringKey: String {
        return DeviceIdStorage.key
    }
}

