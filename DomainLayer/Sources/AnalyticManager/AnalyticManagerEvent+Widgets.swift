//
//  Widgets.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    enum Widgets: AnalyticManagerEventInfo {
        
        case marketPulseClassicActive
        case marketPulseClassicAdded
        case marketPulseDarkActive
        case marketPulseDarkAdded

        public var name: String {
            
            switch self {
            case .marketPulseClassicActive:
                return "Market Pulse Classic Active"
                
            case .marketPulseClassicAdded:
                return "Market Pulse Classic Added"
                
            case .marketPulseDarkActive:
                return "Market Pulse Dark Active"
                
            case .marketPulseDarkAdded:
                return "Market Pulse Dark Added"
            }
        }
        
        public var params: [String : String] {
            switch self {          
            default:
                return [:]
            }
        }
    }
}
