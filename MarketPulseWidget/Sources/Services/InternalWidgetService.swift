//
//  InternalWidgetService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer
import Moya

protocol InternalWidgetServiceProtocol {
    var dataUrl: URL { get }
    var matcherUrl: URL { get }
}

internal class InternalWidgetService: InternalWidgetServiceProtocol {

    let dataUrl: URL
    let matcherUrl: URL
    
    init(dataUrl: URL, matcherUrl: URL) {
        self.dataUrl = dataUrl
        self.matcherUrl = matcherUrl
    }
}

extension InternalWidgetService {
    
    static func moyaProvider<Target: TargetType>() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(callbackQueue: nil,
                                    plugins: [])
    }
}

