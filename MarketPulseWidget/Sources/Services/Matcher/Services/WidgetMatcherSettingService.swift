//
//  WidgetMatcherSettingService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import Moya

protocol WidgetMatcherSettingServiceProtocol {
    func settings() -> Observable<MatcherService.DTO.Setting>
}

final class WidgetMatcherSettingService: WidgetMatcherSettingServiceProtocol {

    private let settingsProvider: MoyaProvider<WidgetMatcherService.Target.Settings> = InternalWidgetService.moyaProvider()

    func settings() -> Observable<MatcherService.DTO.Setting> {

        return settingsProvider
            .rx
            .request(.init(kind: .settings,
                           matcherUrl: InternalWidgetService.shared.matcherUrl),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
            .filterSuccessfulStatusAndRedirectCodes()
            .catchError({ (error) -> Single<Response> in
                return Single.error(NetworkError.error(by: error))
            })
            .asObservable()
            .map(MatcherService.DTO.Setting.self)
    }
}
