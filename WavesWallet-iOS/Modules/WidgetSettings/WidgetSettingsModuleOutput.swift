//
//  WidgetSettingsModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

protocol WidgetSettingsModuleOutput: AnyObject {
    
    func widgetSettingsSyncAssets(_ current: [DomainLayer.DTO.Asset], maxCountAssets: Int, callback: @escaping (([DomainLayer.DTO.Asset]) -> Void))
    func widgetSettingsChangeInterval(_ selected: WidgetSettings.DTO.Interval?, callback: @escaping (_ interval: WidgetSettings.DTO.Interval) -> Void)
    func widgetSettingsChangeStyle(_ selected: WidgetSettings.DTO.Style?, callback: @escaping (_ style: WidgetSettings.DTO.Style) -> Void)
    
}

