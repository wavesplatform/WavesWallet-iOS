//
//  WidgetSettingsModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

protocol WidgetSettingsModuleOutput: AnyObject {
    
    func widgetSettingsAddAsset(callback: @escaping (_ asset: DomainLayer.DTO.Asset) -> Void)
    func widgetSettingsChangeInterval(callback: @escaping (_ asset: WidgetSettings.DTO.Interval) -> Void)
    func widgetSettingsChangeStyle(callback: @escaping (_ asset: WidgetSettings.DTO.Style) -> Void)
    
}
