//
//  CachePolicyPlugin.swift
//  DataLayer
//
//  Created by rprokofev on 07.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Moya

final class CachePolicyPlugin: PluginType {
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutableRequest = request
        mutableRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return mutableRequest
    }
}
