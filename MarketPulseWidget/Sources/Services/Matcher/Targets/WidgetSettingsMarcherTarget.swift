//
//  WidgetSettingsMarcherTarget.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDK

extension WidgetMatcherService.Target {
    
    struct Settings {
        
        enum Kind {
            case settings
        }
        
        var kind: Kind
        var matcherUrl: URL
    }
}

extension WidgetMatcherService.Target.Settings: WidgetMatcherTargetType {
    
    fileprivate enum Constants {
        static let matcher = "matcher"
        static let settings = "settings"
    }
    
    var path: String {
        switch kind {
            
        case .settings:
            return Constants.matcher + "/" + Constants.settings
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String: String]? {
        return ContentType.applicationJson.headers
    }
}
