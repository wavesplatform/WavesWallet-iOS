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

final class BlockRepositoryRemote: BlockRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocol
    private let blockNode: MoyaProvider<Node.Service.Blocks> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func height() -> Observable<Int64> {

        return environmentRepository
            .environment()
            .flatMap({ [weak self] environment -> Single<Response> in
                guard let owner = self else { return Single.never() }
                return owner
                    .blockNode
                    .rx
                    .request(Node.Service.Blocks(environment: environment,
                                                 kind: .height))
            })
            .map(Node.DTO.Block.self)
            .asObservable()
            .map { $0.height }        
    }
}
