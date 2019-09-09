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
import DomainLayer
import WavesSDK
import WavesSDKCrypto

final class WidgetMatcherRepositoryRemote: MatcherRepositoryProtocol {
   
    private let settingsMatcherService: WidgetMatcherSettingServiceProtocol = WidgetMatcherSettingService()
    private let publicKeyMatcherService: PublicKeyMatcherServiceProtocol = WidgetPublicKeyMatcherService()
    
    func settingsIdsPairs() -> Observable<[String]> {

        return settingsMatcherService
                .settings()
                .map {
                    return $0.priceAssets
                }
    }
    
    func matcherPublicKey() -> Observable<PublicKeyAccount> {
        return publicKeyMatcherService
                .publicKey()
                .map {
                    return PublicKeyAccount(publicKey: Base58Encoder.decode($0))
                }
    }
}
