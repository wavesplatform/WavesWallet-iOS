//
//  AliasApiService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/30/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDKExtension

extension API.Service {
    
    struct Alias {
        enum Kind {
            case alias(name: String)
            case list(accountAddress: String)
        }
        
        let environment: Environment
        let kind: Kind
    }
}



extension API.Service.Alias: ApiTargetType {

    private enum Constants {
        static let aliases = "aliases"
        static let address = "address"
    }
    
    var path: String {
        switch kind {
            
        case .alias(let name):
            return Constants.aliases + "/" + "\(name)"
            
        case .list:
            return Constants.aliases
        }
    }
    
    var method: Moya.Method {
       return .get
    }
    
    var task: Task {
        switch kind {
        case .alias:
            return .requestPlain
        
        case .list(let accountAddress):
            return .requestParameters(parameters: [Constants.address : accountAddress], encoding: URLEncoding.default)
        }
    }
}
