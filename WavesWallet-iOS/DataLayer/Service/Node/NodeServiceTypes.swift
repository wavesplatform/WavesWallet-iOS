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
import WavesSDKExtension

enum Node {}

extension Node {
    enum DTO {}
    enum Service {}
}

protocol NodeTargetType: BaseTargetType {}

extension NodeTargetType {
    var baseURL: URL { return environment.servers.nodeUrl }    
}

extension MoyaProvider {
    final class func nodeMoyaProvider<Target: TargetType>() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(callbackQueue: nil,
                            plugins: [SentryNetworkLoggerPlugin(), NodePlugin()])
    }
}
