//
//  ConfirmRequestType.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import Extensions
import DomainLayer

enum ConfirmRequest {
    
    struct State {
        
        struct UI: DataSourceProtocol {
            
            enum Action {
                case none
                case update
            }
            
            var sections: [Section]
            var action: Action
        }
        
        struct Core {
            
            enum Action {
                case none
            }
            
            var action: Action
        }
        
        var ui: UI
        var core: Core
    }
    
    enum Event {
        case none
        case viewDidAppear
    }
    
    struct Section: SectionProtocol {
        var rows: [Row]
    }
    
    enum Row {
        case kind
        case fromTo
        case keyValue
        case doubleKeyValue
        case buttons
//        case skeleton
    }
}


