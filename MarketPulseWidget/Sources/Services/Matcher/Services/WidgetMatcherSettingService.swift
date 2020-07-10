//
//  WidgetMatcherSettingService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK

protocol WidgetMatcherSettingServiceProtocol {
    func settings() -> Observable<MatcherService.DTO.Setting>
}

final class WidgetMatcherSettingService: WidgetMatcherSettingServiceProtocol {
    private let settingsProvider: MoyaProvider<WidgetMatcherService.Target.Settings> = InternalWidgetService.moyaProvider()

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func settings() -> Observable<MatcherService.DTO.Setting> {
        environmentRepository.walletEnvironment()
            .flatMap { [weak self] enviroment -> Observable<MatcherService.DTO.Setting> in

                guard let self = self else { return Observable.never() }
                return self.settingsProvider
                    .rx
                    .request(.init(kind: .settings,
                                   matcherUrl: enviroment.servers.matcherUrl),
                             callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError { (error) -> Single<Response> in
                        Single.error(NetworkError.error(by: error))
                    }
                    .asObservable()
                    .map(MatcherService.DTO.Setting.self)
            }
    }
}
