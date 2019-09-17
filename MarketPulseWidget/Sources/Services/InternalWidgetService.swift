//
//  InternalWidgetService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Moya

protocol InternalWidgetServiceProtocol {
    var dataUrl: URL { get }
    var matcherUrl: URL { get }
}

internal class InternalWidgetService: InternalWidgetServiceProtocol {
    
    static var shared = InternalWidgetService()
    
    var dataUrl: URL {
        return WalletEnvironment.Mainnet.servers.dataUrl
    }
    
    var matcherUrl: URL {
        return WalletEnvironment.Mainnet.servers.matcherUrl
    }
}

extension InternalWidgetService {
    
    static func moyaProvider<Target: TargetType>() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(callbackQueue: nil,
                                    plugins: [])
    }
}

