//
//  BlockRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK
import DomainLayer

// TODO: Rename to Services
final class BlockRepositoryRemote: BlockRepositoryProtocol {
    
    private let wavesSDKServices: WavesSDKServices
    
    init(wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
    }
    
    func height(serverEnvironment: ServerEnvironment,
                accountAddress: String) -> Observable<Int64> {
        
        return wavesSDKServices
            .wavesServices(environment: serverEnvironment)
            .nodeServices
            .blocksNodeService
            .height(address: accountAddress)
            .map { $0.height }
        
    }
}
