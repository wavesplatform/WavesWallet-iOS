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

    private let blockNode: MoyaProvider<Node.Service.Blocks> = .init(plugins: [SweetNetworkLoggerPlugin(verbose: true)])

    func height() -> Observable<Int64> {

        return blockNode
            .rx
            .request(.height)
            .map(Node.DTO.Block.self)
            .asObservable()
            .map { $0.height }        
    }
}
