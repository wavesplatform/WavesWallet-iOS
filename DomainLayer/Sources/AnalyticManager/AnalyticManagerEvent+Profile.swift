//
//  Profile.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    enum Profile: AnalyticManagerEventInfo {
        
        private static let key = "Currency"
        
        case profileAddressAndKeys
        
        case profileLanguage
        
        case profileBackupPhrase
        
        case profileChangePassword
        
        case profileChangePasscode
        
        case profileNetwork
        
        case profileRateApp
        
        case profileFeedback
        
        case profileSupport
        
        case profileDeleteAccount
        
        case profileLogoutUp
        
        case profileLogoutDown
        
        public var name: String {
            switch self {
            case .profileAddressAndKeys:
                return "Profile Address and Keys"
                
            case .profileLanguage:
                return "Profile Language"
                
            case .profileBackupPhrase:
                return "Profile Backup Phrase"
                
            case .profileChangePassword:
                return "Profile Change Password"
                
            case .profileChangePasscode:
                return "profileChangePasscode"
                
            case .profileNetwork:
                return "Profile Network"
                
            case .profileRateApp:
                return "Profile Rate App"
                
            case .profileFeedback:
                return "Profile Feedback"
                
            case .profileSupport:
                return "Profile Support"
                
            case .profileDeleteAccount:
                return "Profile Delete Account"
                
            case .profileLogoutUp:
                return "Profile Logout Up"
                
            case .profileLogoutDown:
                return "Profile Logout Down"
            }
        }
        
        public var params: [String : String] {
            return [:]
        }
    }
}
