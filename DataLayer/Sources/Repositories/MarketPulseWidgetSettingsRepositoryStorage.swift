//
//  MarketPulseWidgetSettingsRepositoryStorage.swift
//  DataLayer
//
//  Created by rprokofev on 07.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

final class MarketPulseWidgetSettingsRepositoryStorage: MarketPulseWidgetSettingsRepositoryProtocol {
    
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        return Observable.never()
    }
}
