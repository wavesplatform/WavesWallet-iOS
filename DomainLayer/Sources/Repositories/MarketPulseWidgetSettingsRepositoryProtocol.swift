//
//  MarketPulseWidgetSettingsRepositoryProtocol.swift
//  DomainLayer
//
//  Created by Pavel Gubin on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol MarketPulseWidgetSettingsRepositoryProtocol {
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings>
}
