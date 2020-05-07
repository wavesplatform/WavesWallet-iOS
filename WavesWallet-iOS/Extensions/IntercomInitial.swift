//
//  IntercomInit.swift
//  DomainLayer
//
//  Created by rprokofev on 29.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions

public struct IntercomInitial: TSUD, Codable {
                
    public var apns: Data? = nil
    // key = address,  valis - is init intercom
    public var accounts: [String: Bool] = [:]
            
    private static let key = "com.waves.intercomInitial"
                
    public init() { }
    
    public static var defaultValue: IntercomInitial {
        return IntercomInitial()
    }
    
    public static var stringKey: String {
        return key
    }
}
