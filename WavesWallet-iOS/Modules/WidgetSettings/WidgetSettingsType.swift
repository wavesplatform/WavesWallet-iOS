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

    enum DTO {
        enum Interval {
            case m1
            case m5
            case m10
            case manually
        }
        
        enum Style {
            case classic
            case dark
        }
    }
    
    struct State {
        
        struct UI: DataSourceProtocol {
            
            enum Action {
                case none
                case update
                case deleteRow(indexPath: IndexPath)
            }
            
            var sections: [Section]
            var action: Action
        }
        
        struct Core {
            
            enum Action {
                case none
                case deleteAsset(_ asset: DomainLayer.DTO.Asset)
                case addAsset(_ asset: DomainLayer.DTO.Asset)
                case changeInterval(_ internal: WidgetSettings.DTO.Interval)
                case changeStyle(_ style: WidgetSettings.DTO.Style)
            }
            
            var action: Action
            var interval: WidgetSettings.DTO.Interval
            var style: WidgetSettings.DTO.Style
        }
        
        var ui: UI
        var core: Core
    }
    
    enum Event {
        case viewDidAppear
        
        case handlerError(_ error: Error)
        
        case rowDelete(indexPath: IndexPath)
        case moveRow(from: IndexPath, to: IndexPath)
                
        case addAsset(_ asset: DomainLayer.DTO.Asset)
        case changeInterval(_ interval: WidgetSettings.DTO.Interval)
        case changeStyle(_ style: WidgetSettings.DTO.Style)        
    }
    
    struct Section: SectionProtocol {
        var rows: [Row]
        var limitAssets: Int
    }
    
    enum Row {
        case asset(WidgetSettingsAssetCell.Model)
    }
}

extension WidgetSettings.Row {
    
    var asset: DomainLayer.DTO.Asset? {
        switch self {
        case .asset(let model):
            return model.asset
        default:
            return nil
        }
    }
}
