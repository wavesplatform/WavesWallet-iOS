//
//  AnalyticManagerEvent+ImportAccount.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    
    enum ImportAccount {
        
        case startImportScan
        case startImportManually
        
        public var name: String {
            
            switch self {
            case .startImportScan:
                return "Start Import Scan"
                
            case .startImportManually:
                return "Start Import Manually"
            }
        }
        
        public var params: [String : String] {
            return [:]
        }
    }
}

