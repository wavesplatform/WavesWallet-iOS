//
//  WidgetSettingsModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import RxSwift

protocol WidgetSettingsModuleOutput: AnyObject {
    func widgetSettingsSyncAssets(_ current: [Asset], minCountAssets: Int, maxCountAssets: Int,
                                  callback: @escaping (([Asset]) -> Void))
    func widgetSettingsChangeInterval(_ selected: DomainLayer.DTO.Widget.Interval?,
                                      callback: @escaping (_ interval: DomainLayer.DTO.Widget.Interval) -> Void)
    func widgetSettingsChangeStyle(_ selected: DomainLayer.DTO.Widget.Style?,
                                   callback: @escaping (_ style: DomainLayer.DTO.Widget.Style) -> Void)
    func widgetSettingsClose()
}
