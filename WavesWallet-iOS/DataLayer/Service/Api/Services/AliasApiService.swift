//
//  AliasApiService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/30/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Moya

extension API.Service {
    
    struct Alias {
        enum Kind {
            case alias(name: String)
        }
        
        let environment: Environment
        let kind: Kind
    }
}



extension API.Service.Alias: ApiTargetType {

    private enum Constants {
        static let aliases = "aliases"
    }
    
    var path: String {
        switch kind {
            
        case .alias(let name):
            return Constants.aliases + "/" + "\(name)"
        }
    }
    
    var method: Moya.Method {
        switch kind {
        
        case .alias:
            return .get
        }
    }
    
    var task: Task {
        switch kind {

        case .alias:
            return .requestPlain
        }
    }
}
