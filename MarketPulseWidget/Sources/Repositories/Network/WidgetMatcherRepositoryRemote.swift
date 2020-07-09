//
//  WidgetMatcherRepositoryRemote.swift
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
import WavesSDKCrypto

final class WidgetMatcherRepositoryRemote {
    
    private lazy var settingsMatcherService: WidgetMatcherSettingServiceProtocol =
        WidgetMatcherSettingService(environmentRepository: environmentRepository)
    
    private lazy var publicKeyMatcherService: PublicKeyMatcherServiceProtocol =
        WidgetPublicKeyMatcherService(environmentRepository: environmentRepository)

    private let environmentRepository: EnvironmentRepositoryProtocol

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func settingsIdsPairs() -> Observable<[String]> {
        return settingsMatcherService
            .settings()
            .map {
                return $0.priceAssets
            }
    }

    func matcherPublicKey() -> Observable<DomainLayer.DTO.PublicKey> {
        
        let environmentKind = self.environmentRepository.environmentKind
        
        return publicKeyMatcherService
            .publicKey()
            .map {
                return DomainLayer.DTO.PublicKey(publicKey: Base58Encoder.decode($0),
                                                 enviromentKind: environmentKind)
            }
    }
}
