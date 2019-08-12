//
//  MarketPulseWidgetSettingsRepositoryProtocol.swift
//  DomainLayer
//
//  Created by Pavel Gubin on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol WidgetSettingsRepositoryProtocol {
    
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings>
    
    func saveSettings(_ settings: DomainLayer.DTO.MarketPulseSettings) -> Observable<DomainLayer.DTO.MarketPulseSettings>
}
