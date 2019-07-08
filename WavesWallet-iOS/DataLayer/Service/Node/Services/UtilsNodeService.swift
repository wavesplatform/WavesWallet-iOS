//
//  UtilsNodeService.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/12/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Moya
import WavesSDKExtension
import WavesSDKCrypto

extension Node.Service {
    
    struct Utils {
        enum Kind {
            case time
        }
        
        let environment: Environment
        let kind: Kind
    }
}

extension Node.Service.Utils: NodeTargetType {
    
    private enum Constants {
        static let utils = "utils"
        static let time = "time"
    }
    
    var path: String {
        switch kind {
        case .time:
            return Constants.utils + "/" + Constants.time
        }
    }
    
    var method: Moya.Method {
        switch kind {
        case .time:
            return .get
        }
    }
    
    var task: Task {
        switch kind {
        case .time:
            return .requestPlain
        }
    }
}
