//
//  BlockRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer

final class BlockRepositoryRemote: BlockRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocols
    
    init(environmentRepository: EnvironmentRepositoryProtocols) {
        self.environmentRepository = environmentRepository
    }

    func height(accountAddress: String) -> Observable<Int64> {

        return environmentRepository
            .servicesEnvironment()            
            .flatMap({ (servicesEnvironment) -> Observable<Int64> in

                return servicesEnvironment
                    .wavesServices
                    .nodeServices
                    .blocksNodeService
                    .height(address: accountAddress)
                    .map { $0.height }
            })
    }
}
