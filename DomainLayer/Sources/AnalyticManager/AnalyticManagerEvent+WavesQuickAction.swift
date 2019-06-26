//
//  WavesQuickAction.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    
    enum WavesQuickAction: AnalyticManagerEventInfo {
        
        private static let key = "Currency"
        
        case wavesActionPanel
        
        case wavesActionSend
        
        case wavesActionReceive
        
        public var name: String {
            switch self {
            case .wavesActionPanel:
                return "Waves Action Panel"
                
            case .wavesActionSend:
                return "Waves Action Send"
                
            case .wavesActionReceive:
                return "Waves Action Receive"
            }
        }
        
        public var params: [String : String] {
            return [:]
        }
    }
}
