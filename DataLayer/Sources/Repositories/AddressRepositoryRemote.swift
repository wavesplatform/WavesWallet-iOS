//
//  AddressRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer
import Extensions

//TODO: Rename to Services
final class AddressRepositoryRemote: AddressRepositoryProtocol {

    private let environmentRepository: ExtensionsEnvironmentRepositoryProtocols
    
    init(environmentRepository: ExtensionsEnvironmentRepositoryProtocols) {
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
