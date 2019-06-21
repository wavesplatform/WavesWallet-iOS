//
//  AddressRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer
import Extensions

final class AddressRepositoryRemote: AddressRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }
    
    func isSmartAddress(accountAddress: String) -> Observable<Bool> {
        
        return environmentRepository
            .servicesEnvironment()
            .flatMapLatest({ (servicesEnvironment) -> Observable<Bool> in
                
                return servicesEnvironment
                    .wavesServices
                    .nodeServices
                    .addressesNodeService
                    .scriptInfo(address: accountAddress)
                    .map { ($0.extraFee ?? 0) > 0 }
            })
    }
}
