//
//  MatcherRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDKCrypto
import WavesSDK
import DomainLayer
import Extensions

final class MatcherRepositoryRemote: MatcherRepositoryProtocol {
    
    private let wavesSDKServices: WavesSDKServices
    
    init(wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
    }
    
    func matcherPublicKey(serverEnvironment: ServerEnvironment) -> Observable<DomainLayer.DTO.PublicKey> {
        
        return wavesSDKServices
            .wavesServices(environment: serverEnvironment)
            .matcherServices
            .publicKeyMatcherService
            .publicKey()
            .map {
                return DomainLayer.DTO.PublicKey(publicKey: Base58Encoder.decode($0))
        }
    }
    
    func settingsIdsPairs(serverEnvironment: ServerEnvironment) -> Observable<[String]> {
        
        return wavesSDKServices
            .wavesServices(environment: serverEnvironment)
            .matcherServices
            .orderBookMatcherService
            .settings()
            .map {
                return $0.priceAssets
            }
    }
}
