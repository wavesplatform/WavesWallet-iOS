//
//  WidgetMatcherRepositoryRemote.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import DomainLayer
import WavesSDK
import WavesSDKCrypto

final class WidgetMatcherRepositoryRemote {
   
    private let settingsMatcherService: WidgetMatcherSettingServiceProtocol = WidgetMatcherSettingService()
    private let publicKeyMatcherService: PublicKeyMatcherServiceProtocol = WidgetPublicKeyMatcherService()
    
    func settingsIdsPairs() -> Observable<[String]> {

        return settingsMatcherService
                .settings()
                .map {
                    return $0.priceAssets
                }
    }
    
    func matcherPublicKey() -> Observable<DomainLayer.DTO.PublicKey> {
        return publicKeyMatcherService
                .publicKey()
                .map {
                    return DomainLayer.DTO.PublicKey(publicKey: Base58Encoder.decode($0))
                }
    }
}
