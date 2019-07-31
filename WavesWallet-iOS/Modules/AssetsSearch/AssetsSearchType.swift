//
//  WidgetSettingsType.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import Extensions
import DomainLayer

enum WidgetSettings {
        
    struct State {
        
        struct UI {
            
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
        case viewDidAppear
        case deleteAsset(indexPath: IndexPath)
        case addAsset(_ asset: DomainLayer.DTO.Asset)
        case handlerError(_ error: Error)
    }
    
    struct Section: SectionProtocol {
        var rows: [Row]
//        var maxAmountAssets: Int
    }
    
    enum Row {
        case asset(WidgetSettingsAssetCell.Model)
    }
}
