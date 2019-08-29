//
//  WidgetMatcherRepositoryRemote.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK

protocol WidgetMatcherRepositoryProtocol {
    func settingsIdsPairs() -> Observable<[String]>
}

final class WidgetMatcherRepositoryRemote: WidgetMatcherRepositoryProtocol {
  
    private let settingsMatcherService: WidgetMatcherSettingServiceProtocol = WidgetMatcherSettingService()

    func settingsIdsPairs() -> Observable<[String]> {

        return settingsMatcherService
                .settings()
                .map {
                    return $0.priceAssets
                }
    }
}
