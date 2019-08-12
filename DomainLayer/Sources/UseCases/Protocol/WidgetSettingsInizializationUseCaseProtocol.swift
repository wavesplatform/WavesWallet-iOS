//
//  MarketPulseWidgetUseCaseProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public protocol MarketPulseWidgetUseCaseProtocol {
    func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings>
}
