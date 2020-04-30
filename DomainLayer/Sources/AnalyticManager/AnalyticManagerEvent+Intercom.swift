//
//  AnalyticManagerEvent+Intercom.swift
//  DomainLayer
//
//  Created by rprokofev on 30.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    
    enum Intercom: AnalyticManagerEventInfo {
        
//        При первом и повторном нажатием на кнопку открытие чата
        case intercomButtonTap
//        При первом нажатие на кнопку открытие чата
        case intercomInit
        
        public var name: String {
            
            switch self {
            case .intercomButtonTap:
                return "Intercom Button Tap "
                
            case .intercomInit:
                return "Intercom Init"
            }
        }
        
        public var params: [String : String] {
            return [:]
        }
    }
}
