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
import WavesSDKServices

final class BlockRepositoryRemote: BlockRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocol
    private let blocksNodeService = ServicesFactory.shared.blocksNodeService
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func height(accountAddress: String) -> Observable<Int64> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] environment -> Observable<Int64> in

                guard let self = self else { return Observable.never() }
                
                return self
                    .blocksNodeService
                    .height(address: accountAddress,
                            enviroment: environment.environmentServiceNode)
                    .map { $0.height }
            })
    }
}
