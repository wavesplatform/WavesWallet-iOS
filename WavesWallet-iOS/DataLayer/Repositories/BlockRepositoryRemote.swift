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

final class BlockRepositoryRemote: BlockRepositoryProtocol {

    private let applicationEnviroment: Observable<ApplicationEnviroment>
    
    init(applicationEnviroment: Observable<ApplicationEnviroment>) {
        self.applicationEnviroment = applicationEnviroment
    }

    func height(accountAddress: String) -> Observable<Int64> {

        return applicationEnviroment
            .flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<Int64> in

                guard let self = self else { return Observable.never() }
                
                return applicationEnviroment
                    .services
                    .nodeServices
                    .blocksNodeService
                    .height(address: accountAddress)
                    .map { $0.height }
            })
    }
}
