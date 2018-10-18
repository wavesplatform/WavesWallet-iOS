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

        return blockNode
            .rx
            .request(Node.Service.Blocks(environment: Environments.current,
                                         kind: .height))
            .map(Node.DTO.Block.self)
            .asObservable()
            .map { $0.height }        
    }
}
