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
import WavesSDKCrypto
import WavesSDKServices

final class MatcherRepositoryRemote: MatcherRepositoryProtocol {

    private let matcherService: PublicKeyMatcherServiceProtocol = ServicesFactory.shared.publicKeyMatcherService
    private let environmentRepository: EnvironmentRepositoryProtocol
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }
    
    func matcherPublicKey(accountAddress: String) -> Observable<PublicKeyAccount> {
        
        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<PublicKeyAccount> in
                guard let self = self else { return Observable.empty() }
                
                return self
                    .matcherService
                    .publicKey(enviroment: environment.environmentServiceMatcher)
                    .map {
                        return PublicKeyAccount(publicKey: Base58.decode($0))
                    }
            })
    }
}
