//
//  NodeTargetType.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

extension MoyaProvider {
    
    final class func anyMoyaProvider<Target: TargetType>() -> MoyaProvider<Target> {
        
        return MoyaProvider<Target>(callbackQueue: nil,
                                    plugins: [SentryNetworkLoggerPlugin(), CachePolicyPlugin()])
    }
}
