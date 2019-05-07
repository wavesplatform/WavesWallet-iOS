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
import WavesSDKServices
import WavesSDKCrypto

extension WavesSDKCrypto.Environment {
    
    var environmentServiceNode: WavesSDKServices.EnviromentService {
        return EnviromentService(serverUrl: servers.nodeUrl,
                                 timestampServerDiff: timestampServerDiff)
    }
    
    var environmentServiceMatcher: WavesSDKServices.EnviromentService {
        return EnviromentService(serverUrl: servers.matcherUrl,
                                 timestampServerDiff: timestampServerDiff)
    }
    
    var environmentServiceData: WavesSDKServices.EnviromentService {
        return EnviromentService(serverUrl: servers.dataUrl,
                                 timestampServerDiff: timestampServerDiff)
    }
}

final class AddressRepositoryRemote: AddressRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocol
    
    private let addressesNodeService = ServicesFactory.shared.addressesNodeService
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func isSmartAddress(accountAddress: String) -> Observable<Bool> {

        let environment = environmentRepository.accountEnvironment(accountAddress: accountAddress)

        return environment
            .flatMap { [weak self] environment -> Observable<Bool> in
                
                guard let self = self else { return Observable.never() }
                
                return self.addressesNodeService
                    .scriptInfo(address: accountAddress,
                                enviroment: environment.environmentServiceNode)
                    .map { ($0.extraFee ?? 0) > 0 }
            }
    }
}
