//
//  WidgetDataService.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

enum WidgetDataService {}

extension WidgetDataService {
    internal enum Target {}
    enum DTO {}
    enum Query {}
}

protocol WidgetDataTargetType: TargetType {
    var dataUrl: URL { get }
}

extension WidgetDataTargetType {
    
    private var dataVersion: String {
        return "/v0"
    }
    
    var baseURL: URL { return URL(string: "\(dataUrl.relativeString)\(dataVersion)")! }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return ContentType.applicationJson.headers
    }
}
