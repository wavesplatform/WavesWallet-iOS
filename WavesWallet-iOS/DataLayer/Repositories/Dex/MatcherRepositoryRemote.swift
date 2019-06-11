//
//  MatcherRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Base58

import WavesSDK

final class MatcherRepositoryRemote: MatcherRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }
    
    func matcherPublicKey(accountAddress: String) -> Observable<PublicKeyAccount> {
        
        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ [weak self] (servicesEnvironment) -> Observable<PublicKeyAccount> in
            
                guard let self = self else { return Observable.empty() }
                
                return servicesEnvironment
                    .wavesServices
                    .matcherServices
                    .publicKeyMatcherService
                    .publicKey()                                        
                    .map {
                        return PublicKeyAccount(publicKey: Base58.decode($0))
                    }
            })
    }
}
