//
//  SingIn.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    
    enum SingIn {
        
        case startAccountEdit
        case startAccountDelete
        case startAccountCounter(Int)
        
        public var name: String {
            
            switch self {
            case .startAccountEdit:
                return "Start Account Edit"
                
            case .startAccountDelete:
                return "Start Account Delete"
                
            case .startAccountCounter:
                return "Start Account Counter"
            }
        }
        
        public var params: [String : String] {
            switch self {
            case .startAccountCounter(let count):
                return ["Count" : "\(count)"]
                
            default:
                return [:]
            }
        }
    }
}

