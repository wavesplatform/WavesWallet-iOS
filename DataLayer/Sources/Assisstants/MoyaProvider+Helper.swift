//
//  NodeTargetType.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Result
import Moya

extension MoyaProvider {    
    final class func anyMoyaProvider<Target: TargetType>() -> MoyaProvider<Target> {
        
//        TODO: Library
//        SentryNetworkLoggerPlugin()
        return MoyaProvider<Target>(callbackQueue: nil,
                                    plugins: [])
    }
}
