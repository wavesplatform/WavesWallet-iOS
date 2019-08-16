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

extension DomainLayer.DTO.Widget.Interval {
    
    var title: String {
        switch self {
        case .m1:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.m1
            
        case .m5:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.m5
            
        case .m10:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.m10
            
        case .manually:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changeinterval.Element.manually
        }
    }
    
    static var all: [DomainLayer.DTO.Widget.Interval] {
        return [.m1, .m5, .m10, .manually]
    }
}

extension DomainLayer.DTO.Widget.Style {
    
    var title: String {
        switch self {
        case .dark:
            return Localizable.Waves.Widgetsettings.Actionsheet.Changestyle.Element.dark
            
        case .classic:
            return  Localizable.Waves.Widgetsettings.Actionsheet.Changestyle.Element.classic
        }
    }
    
    static var all: [DomainLayer.DTO.Widget.Style] {
        return [.classic, .dark]
    }
}


enum WidgetSettings {
    
    struct State {
        
        struct UI: DataSourceProtocol {
            
            enum Action {
                case none
                case update
                case deleteRow(indexPath: IndexPath)
                case error(DisplayError)
            }
            
            var sections: [Section]
            var action: Action
            var isEditing: Bool
        }
        
        struct Core {
            
            enum Action {
                case none
                case settings
                case updateSettings
                case deleteAsset(_ asset: DomainLayer.DTO.Asset)
                case changeInterval(_ internal: DomainLayer.DTO.Widget.Interval)
                case changeStyle(_ style: DomainLayer.DTO.Widget.Style)
                case sortAssets(_ sortMap: [String: Int])
            }
            
            var action: Action
            var invalidAction: Action?
            var assets: [DomainLayer.DTO.Asset]
            var minCountAssets: Int
            var maxCountAssets: Int
            var interval: DomainLayer.DTO.Widget.Interval
            var style: DomainLayer.DTO.Widget.Style
            var sortMap: [String: Int]
            var isInitial: Bool
        }
        
        var ui: UI
        var core: Core
    }
    
    enum Event {
        case none
        case viewDidAppear
        case refresh
        
        case handlerError(_ error: Error)
        
        case rowDelete(indexPath: IndexPath)
        case moveRow(from: IndexPath, to: IndexPath)
        
        case settings(_ settings: DomainLayer.DTO.Widget.Settings)
        case syncAssets(_ assets: [DomainLayer.DTO.Asset])
        case changeInterval(_ interval: DomainLayer.DTO.Widget.Interval)
        case changeStyle(_ style: DomainLayer.DTO.Widget.Style)
    }
    
    struct Section: SectionProtocol {
        var rows: [Row]
        var limitAssets: Int
    }
    
    enum Row {
        case asset(WidgetSettingsAssetCell.Model)
        case skeleton
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
