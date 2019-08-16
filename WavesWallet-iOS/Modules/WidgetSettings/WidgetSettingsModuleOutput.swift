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
    
    func widgetSettingsSyncAssets(_ current: [DomainLayer.DTO.Asset], minCountAssets: Int, maxCountAssets: Int, callback: @escaping (([DomainLayer.DTO.Asset]) -> Void))
    func widgetSettingsChangeInterval(_ selected: DomainLayer.DTO.Widget.Interval?, callback: @escaping (_ interval: DomainLayer.DTO.Widget.Interval) -> Void)
    func widgetSettingsChangeStyle(_ selected: DomainLayer.DTO.Widget.Style?, callback: @escaping (_ style: DomainLayer.DTO.Widget.Style) -> Void)
    func widgetSettingsClose()
}

