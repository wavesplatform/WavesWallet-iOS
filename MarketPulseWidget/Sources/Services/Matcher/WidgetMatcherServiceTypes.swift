//
//  MatcherServiceTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

enum WidgetMatcherService {}

extension WidgetMatcherService {
    enum DTO {}
    enum Query {}
    internal enum Target {}
}

protocol WidgetMatcherTargetType: TargetType {
    var matcherUrl: URL { get }
}

extension WidgetMatcherTargetType {
    
    var baseURL: URL { return matcherUrl }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return ContentType.applicationJson.headers
    }
}
